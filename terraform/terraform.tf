provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {
  backend "s3" {
    bucket  = "data-submission-service-api-terraform-state"
    key     = "dss/terraform.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}

## ECR

resource "aws_ecr_repository" "api" {
  name = "${var.app_name}"
}

## CodePipeline

### Source Bucket
resource "aws_s3_bucket" "source" {
  bucket        = "${var.app_name}-${terraform.workspace}-source"
  acl           = "private"
  force_destroy = true
}

### CodePipeline Role/Policy
data "template_file" "codepipeline_policy" {
  template = "${file("./policies/codepipeline_policy.json.tml")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.app_name}-${terraform.workspace}-codepipeline-role"
  assume_role_policy = "${file("./policies/codepipeline_role.json.tml")}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.app_name}-${terraform.workspace}-codepipeline-policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

### CodeBuild Role/Policy
data "template_file" "codebuild_policy" {
  template = "${file("./policies/codebuild_policy.json.tml")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.app_name}-${terraform.workspace}-codebuild-role"
  assume_role_policy = "${file("./policies/codebuild_role.json.tml")}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.app_name}-${terraform.workspace}-codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

### CodeBuild BuildSpec
data "template_file" "buildspec" {
  template = "${file("./buildspec.yml.tml")}"

  vars {
    aws_account_id  = "${data.aws_caller_identity.current.account_id}"
    image_repo_name = "${var.app_name}"
    rails_env       = "${var.rails_env}"
    task_name       = "dss-infrastructure-${terraform.workspace}-api"
  }
}

resource "aws_codebuild_project" "build" {
  name          = "${var.app_name}-${terraform.workspace}-codebuild"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:1.12.1"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}

### CodePipeline
resource "aws_codepipeline" "pipeline" {
  name     = "${var.app_name}-${terraform.workspace}-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "${var.github_owner}"
        Repo       = "${var.github_repo}"
        Branch     = "${var.git_branch_to_track}"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.app_name}-${terraform.workspace}-codebuild"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${var.ecs_cluster_name}"
        ServiceName = "${var.ecs_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }

}

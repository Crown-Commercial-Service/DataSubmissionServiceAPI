# "Stuck" ingests

[Trello card](https://trello.com/c/gdWr7xIo/1138-returns-take-over-two-weeks-to-process-get-stuck)

## The symptoms

- Supplier continues to see "Processing" screen for a submission, even days after submitting it. There is nothing that the supplier can do to resolve this situation.
- At a data level, this means that the `SubmissionFile` is stuck with `aasm_state == 'processing'`

## Why it happens

1. High RAM usage during `SubmissionIngestionJob` causes the Sidekiq worker to hit its RAM limit and get killed, in the middle of various jobs (the `SubmissionIngestionJob` that caused the error, and any other jobs that are running at the same time, most notably `ManagementChargeCalculationJob`).
2. Our [Sidekiq config](#we-want-automatic-recovery) means that the killed jobs are then lost and not performed again, even once Sidekiq is restarted, so jobs are never resumed and hence the submission remains stuck.

At the time of writing, the Sidekiq RAM limit on prod was [2 GiB](https://github.com/dxw/DataSubmissionServiceAPI/blob/c16cf6b/CF/deploy-app.sh#L108).

### Why high RAM usage?

There are two stages in the ingest process where the RAM usage is very high:

1. Converting the Excel file to CSV using the `in2csv` tool. The memory consumption of this tool increases with the size of the input file (at least, for XLSX files, which is what I tested; Leeky suggested that the structure of an XLS file means that they may be easier to stream from disk).
2. Reading the CSV rows and validating them, in `Ingest::Loader`. We create an [in-memory array](https://github.com/dxw/DataSubmissionServiceAPI/blob/36252c8598ec44865d4a5eefa18b077e88116c13/app/models/ingest/loader.rb#L62) of `SubmissionEntry` instances, which we validate one-by-one and which we then afterwards persist to the database in a single transaction. This array grows in an unbounded fashion with the size of the input file.

So, we see that this is a problem which is more likely to occur for _large files_.

## When it's happened

At the time of writing, we had only had _nine_ stuck ingests on prod (as detected by the query given [here](#manually-finding-stuck-submissions-in-the-database)).

The example that I was testing with is the `SubmissionFile` with ID `c41b0aba-32ed-403c-a0dd-a571039b68bb` on prod (it's one of the examples given on the Trello). This is a 46.6MB Excel file with ~210,000 rows.

At the time of writing, this was the largest file that had been uploaded to prod, and it is much larger than most other files. It was a return for the newly-onboarded RM3735 framework, whose items are things like individual train tickets. Now that this framework has been onboarded, we can expect to continue receiving files of this sort of size (if not larger). Here is the distribution of file sizes on prod:

```
0 - 1   MiB: 13863 (98.034%)
1 - 2   MiB: 132   (0.933%)
2 - 3   MiB: 61    (0.431%)
3 - 4   MiB: 29    (0.205%)
4 - 5   MiB: 23    (0.163%)
5 - 6   MiB: 15    (0.106%)
6 - 7   MiB: 3     (0.021%)
8 - 9   MiB: 2     (0.014%)
9 - 10  MiB: 4     (0.028%)
12 - 13 MiB: 3     (0.021%)
13 - 14 MiB: 1     (0.007%)
14 - 15 MiB: 1     (0.007%)
15 - 16 MiB: 1     (0.007%)
24 - 25 MiB: 2     (0.014%)
44 - 45 MiB: 1     (0.007%)
```

Code for generating the submission file size distribution:

```ruby
def print_submission_file_size_distribution
    submission_file_attachments = ActiveStorage::Attachment.joins(:blob).where(record_type: SubmissionFile.to_s)
    max_size = submission_file_attachments.maximum(:byte_size)
    
    megabyte = 1024 * 1024
    ranges = (max_size/megabyte.to_r).ceil.times.map { |i| (i * megabyte ... [(i + 1) * megabyte - 1, max_size + 1].min) }
    
    total = submission_file_attachments.count
    ranges.each do |range|
    condition = ActiveStorage::Blob.where(byte_size: range)
    count = submission_file_attachments.merge(condition).count
        puts "#{range.min / megabyte} - #{range.min / megabyte + 1} MiB: #{count} (#{sprintf('%.3f', 100 * count.fdiv(total))}%)" if count > 0
    end
end
```

## So, how much RAM _is_ needed for the current ingest to succeed with a large file?

I tried running a single `SubmissionIngestionJob` with the aforementioned large file in the Docker development environment on my local machine, and observed the memory consumption with `docker stats data-submission-service-api_worker`. The job eventually (41 min) succeeded; here is the peak memory consumption observed:

- The _lowest_ memory consumption observed was at the start of the ingest, at around 150MiB.
- The peak consumption during the `in2csv` phase of the ingest was around 1GiB;
- The peak consumption during the subsequent (Ruby) phase of the ingest was around 3.24GiB.

This means that:

- the _most pessimistic estimate_ of the RAM required to be able to ingest three files of this size simultaneously would be (1GiB + 3.24GiB) * <Sidekiq concurrency>. This is assuming that we have <Sidekiq concurrency> Ruby processes which have not yet peformed garbage collection after a previous large ingest by the time that the `in2csv` of the next ingest starts.
- I think it is more likely that we would be starting an ingest from a position where Ruby performs garbage collection towards the end of an ingest, in which case _a more optimistic estimate_ is (3.24GiB) * <Sidekiq concurrency>.

So for a Sidekiq concurrency of 3 this means we should try somewhere between 9.72 and 12.72GiB of RAM. And if we decide that we only want to be able to process one large file and two small files at the same time, then this number can dropped further. But it's clear that 2GiB is not enough to handle even a single large ingest.

## Detecting when it happens

### It would be good if it were automatic...

It would be good to have the following:

* alerts when a container runs out of memory
* graphs of container memory usage
* automatic detection / restarting of "stuck" submissions

However we currently do not have any of these things.

### Manually finding out-of-memory errors in the logs

Searching for "Exit status" in the Papertrail logs shows frequent "Exit status 137 (out of memory)". Here are some examples of times that it happened around the time that an ingest got "stuck":

- [Aug 06 2019 11:40:50](https://papertrailapp.com/systems/3400155202/events?focus=1095345961133359136&q=Exit+status&selected=1095345961133359136)
- [Aug 07 2019 13:37:05](https://papertrailapp.com/systems/3400155202/events?focus=1095737606597197825&q=Exit+status&selected=1095737606597197825)

### Manually finding stuck submissions in the database

You can run this in a Rails console to get all the submissions which have been in a processing state for at least a day (and which haven't been supplanted by a later submission which completed the task - although in theory this shouldn't be possible, at least via the supplier web interface):

```ruby
def stuck_submissions
    Submission.joins(:task).where("aasm_state = 'processing' and submissions.updated_at < ? and tasks.status != 'completed'", Time.now - 1.day).order(updated_at: :asc)
end
```

If you want to pass this information on to CCS, you can format the results with this method, whose results are suitable for pasting into e.g. Trello comment:

```ruby
def pretty_print_for_customer(submissions)
    include ActionView::Helpers::NumberHelper
    submissions.each_with_index do |submission, index|
        raise 'more than one file' unless submission.files.count == 1
        puts("#{index + 1}: #{submission.task.supplier.name} (#{submission.task.framework.short_name}, month #{submission.task.period_month}/#{submission.task.period_year}, #{number_to_human_size(submission.files.first.file.byte_size)}). Stuck since #{submission.updated_at.in_time_zone('Europe/London').strftime('%F %T')}")
    end
end
```

## Prevention of out-of-memory errors

### Proper fix

_(I am only referring to fixing the memory consumption of the _Ruby_ part of the ingest here; fixing `in2csv` is a lower priority since at the moment it is not the bottleneck. That said, I do believe that we will be able to reduce the Ruby consumption, to the point where `in2csv` will _become_ the bottleneck.)_

The high-water mark RAM usage of the ingest process should not be affected by the size of the input file.

This means that we should not have any in-memory arrays which grow in an unbounded fashion.

This can be achieved by processing the CSV file in fixed-size batches, and then either:

1. inserting the `SubmissionEntry` records into the database after the validation of the entries in each batch (this may require a long-running transaction since the validations are not fast, and that might not be good), or
2. streaming the validated `SubmissionEntry` records to a temporary file on disk, and then writing these to the database in a single transaction.

### Options for a "sticking-plaster" fix

These both focus on getting things working for the _largest real-world files that we've seen to date_.

1. Reduce the high-water mark consumption of the ingest process for these files, so that it's within our RAM limit for the Sidekiq workers. This would be done by trying out some small optimisations. For example, instead of an in-memory array of many `SubmissionEntry` instances, keep an array of `Array` instances instead). I have created an example of this fix [here](https://github.com/dxw/DataSubmissionServiceAPI/tree/refactor/1138-reduce-ingest-memory-usage).
2. Increase the RAM on the Sidekiq workers. I do not yet have an idea of how much RAM is _needed_ in order for these files to succeed.

## Recovery from the problem

Although we want to [prevent the out-of-memory errors](#prevention-of-out-of-memory-errors), we should still be able to recover from the case where it occurs. This is for two reasons:

1. We _already_ have some stuck ingests that we need to fix (possibly manually).
2. It will be difficult to guarantee that we have fixed the out-of-memory errors, and it's the sort of error which is quite easy to re-introduce as a regresssion.

### What should the recovery process look like when viewed from outside?

Since this failure is not a result of supplier user error, I think that the recovery should occur without the supplier user being made aware of it, and (hence) without requiring any supplier user intervention (that is, e.g. they shouldn't have to re-submit their return).

**Before attempting any recovery (manual or automatic), we should confirm this with CCS.**

### We want automatic recovery

The ideal behaviour would be that after Sidekiq restarts, it automatically re-runs the killed job from the beginning. However, these links from Sidekiq's documentation make it clear that this is not the default behaviour of Sidekiq, and that we would have to upgrade to Sidekiq Pro to get it:

* ["What happens to long-running jobs when Sidekiq restarts?"](https://github.com/mperham/sidekiq/wiki/FAQ#what-happens-to-long-running-jobs-when-sidekiq-restarts)
* ["every time the Sidekiq process crashes, any messages being processed are lost. You can avoid this with Sidekiq Pro's reliable fetch feature."](https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting#my-sidekiq-process-is-crashing-what-do-i-do)
* ["Sidekiq uses BRPOP to fetch a job from the queue in Redis. This is very efficient and simple but it has one drawback: the job is now removed from Redis. If Sidekiq crashes while processing that job, it is lost forever."](https://github.com/mperham/sidekiq/wiki/Reliability#using-super_fetch)

### Is it safe to re-run `SubmissionIngestionJob`?

I am not sure. I think that it is safe to re-run _as long as there are no other instances of this running for the same `SubmissionFile`_. Needs further investigation.

### Fixing an individual stuck return

__If__ it is [safe to rerun the job](#is-it-safe-to-re-run-submissioningestionjob`), then we can do exactly that:

```ruby
# In a Rails console
SubmissionIngestionJob.perform_later(SubmissionFile.find(<ID>))
```

__Update (30 Aug 2019)__ - CCS actually suggested that for now we simply mark the submissions as failed; they will handle the comms of asking suppliers to re-submit. We can fail a submission [the same way that `SubmissionIngestionJob` does it](https://github.com/dxw/DataSubmissionServiceAPI/blob/fb0385b52afe58aa44d23eb47f94db54c12bbb46/app/jobs/submission_ingestion_job.rb#L24):

```ruby
submission.update!(aasm_state: :ingest_failed)
```

(You will obviously need to tell CCS which submissions you have performed this for.)

## What to do next

- <del>Try [increasing the Sidekiq memory usage](#options-for-a-sticking-plaster-fix)</del> (<del>__update__ (30 Aug 2019) memory has been bumped to 8GiB</del> __update__ (9 Sep 2019) memory has been bumped to 16GiB) and see if we can succesfully ingest the aforementioned [large file](#when-its-happened)
- Decrease Sidekiq concurrency from 30 (I think this comes from the `RAILS_MAX_THREADS` environment variable on prod) to its pre-(GOV.UK PaaS migration) value of 3 (mentioned by Leeky), by setting the [`SIDEKIQ_CONCURRENCY`](https://github.com/dxw/DataSubmissionServiceAPI/blob/36252c8598ec44865d4a5eefa18b077e88116c13/config/sidekiq.yml#L1) environment variable. If decreasing Sidekiq concurrency has an impact on performance on prod, we may wish to consider adding an extra Sidekiq worker instance.
- Consider deploying the [small optimisation](#options-for-a-sticking-plaster-fix).
- Set up an alert from Papertrail to Slack (either to `#ccs-data-submission` or `#ccs-noise`) to send a message when an out of memory error appears in the logs
- Once we've got ascertained whether it's safe to re-run the jobs, consider purchasing Sidekiq Pro, to get automatic recovery
- Start working on a [proper fix](#proper-fix) for the underlying problem

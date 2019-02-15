# Generating email list for outstanding tasks

In order for suppliers to be contacted when they have outstanding tasks to
complete, we have a Rake task to generate a list of the emails of users who
should be contacted.

## How to Use

```
rake chore:outstanding_task_emails
```

This generates a report that is written to /tmp/outstanding_task_emails.txt

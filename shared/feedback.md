# lbdev feedback log

lbdev improves from its own failures. Each command that hits a problem caused by the plugin itself logs it, and `/lbdev:improve` later turns the log into fixes to the plugin.

## Where

`<plugin-data>/feedback.md`, where `<plugin-data>` is the plugin data directory given by the command that loaded this file. It survives plugin updates and is shared by every project on this machine. Create it if it does not exist.

## When to log

Log right when it happens, not at the end: context compaction can erase it.

- The user corrects, complains about or redoes something lbdev produced (format, behaviour, a wrong decision).
- A task reached the maximum number of fix rounds.
- A subagent returned BLOCKED or NEEDS_ANSWERS for a fact the brief should have contained.
- The same verification failed twice in a row on the same task.
- Validators rejected more than half of the findings of one review or audit.
- The git guard hook blocked a command.
- A read-only role changed the working tree fingerprint.
- An instruction of the plugin was impossible, ambiguous or contradicted another one.
- A tool call failed because of how the plugin told you to call it (wrong parameter, missing script).

Do not log problems of the user's project (failing tests the task did not cause, missing dependencies) unless the plugin handled them badly.

## Format

Append one entry per incident:

```
## <YYYY-MM-DD HH:MM> <short-slug> | open
- command: /lbdev:<name> | plugin version: <version from plugin.json>
- kind: error | loop | blocked | user-feedback | false-positives | guard | contradiction
- what happened: <one line>
- suspected cause: <plugin file and section, for example roles/implementer.md "Before coding">
- suggested fix: <one line>
```

## Privacy

The log describes the plugin's behaviour, not the project. No code, no file contents, no secrets, no customer or company names, no absolute paths. Describe the project generically ("Python monorepo with two test suites").

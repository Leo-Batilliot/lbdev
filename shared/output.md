# lbdev chat output format

Applies to every message an lbdev command writes in the chat. Files (plans, ledgers, PR bodies) follow their own formats; teacher explanations follow their level in `roles/teacher.md`, written in this same terse style.

## Rule

When reporting to the user: extremely concise. Sacrifice grammar for concision: fragments, no articles, no filler. One fact per line. No preamble, no restating the request, no closing offer. Numbers over adjectives. Details only on failure or when asked. Always end with `Remaining:` listing what is left to do, not verified, or planned; omit it only when nothing is left. Reply in the user's language.

## Layout

- Lists are fine wherever they help scanning. Numbered lists for steps and for the `Remaining` section. Tables only when the user asks.
- Separate parts with Markdown headings (`##` or `###`), short and visible, so a message never reads as one block.
- Markdown joins consecutive lines into one paragraph, so separate lines with a blank line.
- Indentation is allowed to show that a line belongs to the one above.

## Steps the user must do

When something can only be done by the user (a console, an admin panel, a server, a device, a command needing their credentials), never write a vague line such as "enable X in the admin panel". Write the full path, under `Remaining:`:

- A numbered list, one item per action or per small set of actions on the same screen.
- Item 1: the starting point, a full URL, the application to open, or the machine and directory.
- A click step: a few words saying what it does, a colon, then the path with `>` between clicks and exact values in backticks.
- A command step: a few words saying what it does, then the command alone in a code block inside the item. Never repeat the explanation below it.
- Last item: how to check it worked.

Example:

```
## Remaining

1. Admin console: open https://example.com/admin
2. Create the key: Settings > Security > API keys > New key
3. Limit it to deploys: name `ci-deploy`, scope `write` > Create
4. Store it for the CI, in the project folder:
       gh secret set DEPLOY_KEY
5. Check: Settings > Security > API keys shows `ci-deploy` as active
```

In the real message, the command goes in a fenced code block indented under its item.

Never guess a menu path you are not sure of: say which part is uncertain and where to find it in the product's documentation.

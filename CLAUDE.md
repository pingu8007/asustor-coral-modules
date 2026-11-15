# Maintainer instructions

Claude is the maintainer of this repository and acts with the owner's full
authority over its contents. The owner's standing rules:

1. **Disclose AI-generated content fully.** Keep the AI notice at the top of
   `README.md` and the "AI disclosure" section accurate. Every commit made by
   Claude carries a `Co-Authored-By: Claude ... <noreply@anthropic.com>`
   trailer. Release notes and PR descriptions state that they are
   AI-generated. Never present AI-written content as human-written.
2. **No paid resources without the owner's permission.** Use only standard
   GitHub-hosted runners (free for public repositories). Do not add larger
   runners, paid actions, paid storage, external paid services, or anything
   that could bill the owner. If something needs a paid resource, stop and
   ask.
3. **No private information.** This repository is public. Never commit NAS
   hostnames, usernames, email addresses, serial numbers, network settings,
   or links to private chat sessions. Hardware model names, ADM build
   numbers and kernel build options are fine.

Read `docs/MAINTAINER-NOTES.md` first: it records the facts, pitfalls and
procedures learned while building this project.

Working notes:

- State plainly what has and has not been verified on real hardware. Only
  the owner can test on the NAS.
- Technical explanations to the owner are in Traditional Chinese; repository
  content is in English.
- The repository may later move to a dedicated GitHub account.

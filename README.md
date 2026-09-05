# North TFM cloud runner

This repository contains only scheduling, private-package download and encrypted
artifact handoff code. It does not contain the generator, template, game SWF,
player keys, publishing credential or candidate decryption key.

The pinned toolchain is retrieved from authenticated Cloudflare storage. Build
and publication use separate machines. Public artifacts contain only AES-GCM
encrypted candidates; their random keys are wrapped with the publisher's RSA
public key. Secrets are held in GitHub Actions secrets.

Only manual and scheduled runs on the default branch are enabled. No pull
request workflow executes with these credentials. Standard public runners are
subject to GitHub's current free-use policies and queue delays. A five-minute
schedule is not a guarantee of five-minute update completion.

Automatic publication is controlled by the AUTO_PUBLISH repository variable.
It is disabled until deployment and gameplay checks are complete.

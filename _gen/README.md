# Generating the API reference

`content/docs/integration-guidance/api-reference/pay_*.md` is generated from the
proto snapshot under `proto/` — edit the protos, not the markdown.

```bash
go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest
PATH="$(go env GOPATH)/bin:$PATH" ./_gen/gen.sh
```

Needs `protoc` and `protoc-gen-doc` on `PATH`. Re-running it on an unchanged
snapshot reproduces the committed pages byte for byte, so a dirty `git status`
after a run means the protos moved and the pages had not caught up.

`gen.sh` holds the page list — proto file, title, menu weight — and rewrites
cross-page type links so a type documented on one page is linked from the pages
that use it. Adding a proto to the docs is one line in `PAGES`.

The protos are synced from `t-0-network/backend`; the sync is configured there in
`.github/workflows/proto-sync-config/usdt-pay-docs.yaml`.

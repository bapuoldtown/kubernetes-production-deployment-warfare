# Security policy for this learning repository

This is a public training lab. Never commit passwords, API tokens, personal access tokens, cloud credentials, kubeconfig files, client certificates/private keys, Kubernetes Secret values, or unredacted terminal output containing sensitive information.

Use placeholders such as <REDACTED> in examples. Treat Base64-encoded Kubernetes Secret data as sensitive; Base64 is not encryption.

Use disposable local clusters and synthetic data. Verify the active Kubernetes context before applying or deleting resources. The labs are educational simulations and are not production deployment instructions without environment-specific security, availability, capacity, and change-management review.

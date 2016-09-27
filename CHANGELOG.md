## 1.1.1 (September 27, 2016)

Bugfixes:
  - Fixed the issue with `knife bastion status` plugin, when it sometimes failed to detect bastion host IP address

## 1.1.0 (August 30, 2016)

Changes:
  - Proxy code has been refactored to make it more generic, so it can be used to proxy any requests through bastion connection

Bugfixes:

## 1.0.0 (August 22, 2016)

Features:

  - Connect to bastion server via SSH and proxy all Chef requests through this connection
  - Knife plugins to monitor status, start and stop connections

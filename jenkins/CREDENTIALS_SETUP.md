# Jenkins Credentials Setup

Go to Manage Jenkins -> Credentials -> System -> Global credentials -> Add Credentials

Add these 6 credentials with the exact IDs below (Jenkinsfile references them by ID):

| Credential ID | Kind | Value |
|---|---|---|
| dockerhub-repo | Secret text | your dockerhub username/repo, e.g. myuser/devops-mega-app |
| dockerhub-creds | Username with password | dockerhub username + access token |
| gitops-repo-url | Secret text | git@github.com:myuser/devops-mega-gitops.git |
| gitops-ssh-key | SSH Username with private key | deploy key with push access to gitops repo |
| argocd-server-url | Secret text | wherever argocd is running, e.g. localhost:8080 |
| argocd-auth-token | Secret text | generate via `argocd account generate-token` |

Use a DockerHub access token instead of your real password (Account Settings -> Security -> New Access Token).

If any ID doesn't match what's set in Jenkins, the build fails with "no such credential" - the error tells you which one is missing.

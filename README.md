# Actions Runner Controller demo using Dev Containers

Hi developer 👋🏻! 

With this repo you can test how Actions Runner Controller works using Dev Containers 🐳 So you don't have to deploy any Kubernetes cluster anywhere 🤓

Just clone this and install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) in your Visual Studio Code, create a GitHub App with this permissions:

- **Repository permissions**: `Actions: Read-only` and `Metadata: Read-only`
- **Organization permissions**: `Self-hosted runners: read and write`

Install your GitHub App in your organization and copy your App ID and your Installation ID in a .env file inside .devcontainer folder with this format:

```
GITHUB_APP_ID=<YOUR_GITHUB_APP_ID>
GITHUB_APP_INSTALLATION_ID=<YOUR_GITHUB_APP_INSTALLATION_ID>
```

Last thing is generate a private key for your GitHub App and save it as `private-key.pem` in .devcontainer. And you are ready to go! The only thing missing is to Reopen in Container:

<img src="images/Actions-runner-controller reopen in container.png" />

If you speak/understand Spanish 🇪🇸 you can read the detail here: [Cómo desplegar y escalar GitHub self-hosted runners en Kubernetes](https://www.returngis.net/2024/02/como-desplegar-y-escalar-github-self-hosted-runners-en-kubernetes/)

See you 👋🏻!

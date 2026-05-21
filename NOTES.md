## Notes On Starting Again

The intent of refreshing the RockoperaColor project is to capitalize on recently acquired skills and approaches, resulting in a higher quality product I can more confidently use on its own, and as a basis for the rest of an ecosystem for fully onchain artistry.

## Recipe With Some Detail

### Prepare The Environment

Lay the groundwork with one-line commands, typed in the terminal.

```
mkdir rocolor
cd rocolor
foundryup
forge --version
forge init
```

I was hoping for a forge version of `1.5.1-stable`, which I got, and now I have a project in that `rocolor` folder.

Opening this folder in VS Code, the 'Source Control' tab on the left was where I could start a 'rocolor' repository, and then publish (private) to GitHub, an account for which I had already set up and connected to VS Code via a GH extension.

After commiting with a message, it shows in GitHub.

If you're like me, this is the part where you sigh with relief.

### Code

Code a `.sol` file in the `src` folder, and type in the terminal `forge build` to have it compile, debugging any issues along the way, and commiting to GH along the way.

I started with simple `setName()` and `getName()` functions.

### Deploy Locally

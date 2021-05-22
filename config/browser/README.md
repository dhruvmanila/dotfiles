# Vimium

On GitHub, the transparency does not work. Here's a workaround for that:

1. Clone the repo: `git clone --depth=1 git@github.com:philc/vimium.git ~/git/`
2. Edit `./content_scripts/vimium.css` with the following:

```css
iframe.vimiumUIComponentVisible {
  color-scheme: light;
}
```

3. Open Brave extension settings through `manage extensions`, turn on developer
   mode on top right corner, click on `load unpacked` on top left corner and
   upload the repository.
4. Open the vimium settings and restore the options using `vimium-options.json`.

Credits: https://github.com/philc/vimium/issues/3732#issuecomment-749997600

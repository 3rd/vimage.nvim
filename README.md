# vimage.nvim

Image plugin for Neovim.

This is WIP, will package properly when it's usable.

To use this for experimentation:
  - creating your own ftplugin
  - customizing the syntax matching in `vimage.lua`
  - set `nowrap`

Links:

  - [video - https://www.youtube.com/watch?v=cnt9mPOjrLg](https://www.youtube.com/watch?v=cnt9mPOjrLg)
  - [https://www.reddit.com/r/neovim/comments/ieh7l4/im_building_an_image_plugin_and_need_some_help/](https://www.reddit.com/r/neovim/comments/ieh7l4/im_building_an_image_plugin_and_need_some_help/)

What's missing:

  - ueberzug replacement (rust/go) with image masking and contain_crop scaler
  - ensure images are not rendered outside of their window (including path masking for floating windows)
  - find a better way to compute the visual line height all all lines in the buffer to support wrapping ([this
  works](https://github.com/heapslip/vimage.nvim/blob/master/plugin/vimage.vim#L14) but it's way too slow)
  - find a way to do reverse conceal to add virtual extra lines, there's a [PR open for this](https://github.com/neovim/neovim/pull/9496#issuecomment-453860689)


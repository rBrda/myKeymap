# myKeymap

A simple plugin to list and search key mappings in (neo)vim.

Based on [fzf.vim](https://github.com/junegunn/fzf.vim).

![mykeymap](https://user-images.githubusercontent.com/22145465/98463978-df138280-21bf-11eb-9cdf-660698bb5fc4.png)

## Usage

Let's suppose you defined the following key mappings to navigate between open windows more easily. They look like this:

```vim
" Navigating between open windows
nnoremap <C-l> <C-W>l
nnoremap <C-h> <C-W>h
nnoremap <C-k> <C-W>k
nnoremap <C-j> <C-W>j
```

With the help of this plugin you can add annotations to your key mappings. This way the plugin will be able to find them and list them for you.

```vim
" Navigating between open windows
" @(Windows -> right)
nnoremap <C-l> <C-W>l
" @(Windows -> left)
nnoremap <C-h> <C-W>h
" @(Windows -> up)
nnoremap <C-k> <C-W>k
" @(Windows -> down)
nnoremap <C-j> <C-W>j
```

### How to add annotations to your key bindings?

The annotation must be placed just above the key mapping it belongs to, like this:

```vim
" @(Shift indentation)
vnoremap <Tab> >gv
```
Use descriptive naming for your key bindings so when you list them, it's easier to search them.

Note: you must restart your editor whenever you added or modified the annotations of your key mappings!

### How to list and search your annotated key mappings?

The plugin has the `MyKeymap` command for listing the annotated key mappings. They will be shown in a fzf popup window.

## Installation

With [vim-plug](https://github.com/junegunn/vim-plug):
```
Plug 'rBrda/myKeymap'
```

## Configuration

You can configure the plugin by setting the following global variable in your (neo)vim configuration file (here you see all the properties included that can be modified):

```vim
let g:myKeymapSettings = {
  \ 'show_details': ['action'],
  \ 'disable_cache': 0,
  \ }
```

### `g:myKeymapSettings.show_details`

Default value: `['action']`

Possible values: `['action', 'source']`

This is a list of details that can be shown in the result list about the key mapping.

Meaning of the available values:
* `action` : shows the mapped command of the key mapping
* `source` : shows the source file and line number of the key mapping

### `g:myKeymapSettings.disable_cache`

Default value: `0`

If the cache is turned off (`1`), the plugin will always read your (neo)vim configuration files.

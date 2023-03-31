# Changelog

## [1.1.0](https://github.com/folke/todo-comments.nvim/compare/v1.0.1...v1.1.0) (2023-03-31)


### Features

* **telescope:** access pickers with plugin_name... ([#191](https://github.com/folke/todo-comments.nvim/issues/191)) ([7420337](https://github.com/folke/todo-comments.nvim/commit/7420337c20d766e73eb83b5d17b4ef50331ed4cd))

## [1.0.1](https://github.com/folke/todo-comments.nvim/compare/v1.0.0...v1.0.1) (2023-03-26)


### Bug Fixes

* **icons:** fixed obsolete nerd font icons with nerdfix ([3bddf1d](https://github.com/folke/todo-comments.nvim/commit/3bddf1dc406b9212c881882c8cfc4798ee271762))

## 1.0.0 (2023-01-04)


### ⚠ BREAKING CHANGES

* todo-comments now requires Neovim >= 0.8.0. Use the `neovim-pre-0.8.0` branch for older versions

### Features

* accept argument to filter keywords ([#116](https://github.com/folke/todo-comments.nvim/issues/116)) ([67cd3a4](https://github.com/folke/todo-comments.nvim/commit/67cd3a4112f372bb1406dae35816d502f53a5af3))
* add config option to set gui style ([#117](https://github.com/folke/todo-comments.nvim/issues/117)) ([231888a](https://github.com/folke/todo-comments.nvim/commit/231888aa37ddbdcc8a58b06dcb19dacfa65bf2c7))
* add error logging for rg ([006250f](https://github.com/folke/todo-comments.nvim/commit/006250f11d34fdd4500db5fdde5133131b48bc72))
* add max line len option (Fixes [#33](https://github.com/folke/todo-comments.nvim/issues/33)) ([8b63dfc](https://github.com/folke/todo-comments.nvim/commit/8b63dfccf1ae11aeebc9fae3b3d7a6dd12bb09b5))
* added merge_keywords option that allows disabling the default groups ([3f3b8b4](https://github.com/folke/todo-comments.nvim/commit/3f3b8b4fa8b4b91c2a0142491ee22afd76c161e3))
* added methods to jump to next/prev todo comment ([c88d199](https://github.com/folke/todo-comments.nvim/commit/c88d1997e40cec2078562e405b52be863d60615a))
* added multiline context and pattern ([144cba6](https://github.com/folke/todo-comments.nvim/commit/144cba62f6753647a8c502b25475e5ed568d5358))
* added options.highlight.exclude. Fixes [#41](https://github.com/folke/todo-comments.nvim/issues/41) ([1275879](https://github.com/folke/todo-comments.nvim/commit/12758792a0d207b5a4a4fb5a11a0d321a4608108))
* added support for specifying multiple patterns for highlighting ([808a2e5](https://github.com/folke/todo-comments.nvim/commit/808a2e524b3720804716a99fd900986b9d727d4d))
* added TEST to ([5547b53](https://github.com/folke/todo-comments.nvim/commit/5547b537593a4322f876637c6ee2aa38b2ac50ee))
* added TodoLocList. Fixes [#47](https://github.com/folke/todo-comments.nvim/issues/47) ([c641728](https://github.com/folke/todo-comments.nvim/commit/c6417282c9d3948917e712b8e0b0093f9dc995e2))
* allow changing config on the fly or disable all [#27](https://github.com/folke/todo-comments.nvim/issues/27) ([2f701d0](https://github.com/folke/todo-comments.nvim/commit/2f701d0738e3b0dfae90c69435b752bbbaeb2ed3))
* allow custom todo patterns [#4](https://github.com/folke/todo-comments.nvim/issues/4) ([1732f21](https://github.com/folke/todo-comments.nvim/commit/1732f21854f0d7f9cffd6e92f9e95c13a01bd79e))
* allow searching for todos in another directory. Implements [#21](https://github.com/folke/todo-comments.nvim/issues/21) ([6de90a5](https://github.com/folke/todo-comments.nvim/commit/6de90a566ab50da6b76200a69486b6d51c8d07ee))
* allow specifying wide_fg ([#92](https://github.com/folke/todo-comments.nvim/issues/92)) ([dca8c3f](https://github.com/folke/todo-comments.nvim/commit/dca8c3fa3b515bc85652e50bf736d2cca8a87cb2))
* also deepcopy keywords ([0f6a87b](https://github.com/folke/todo-comments.nvim/commit/0f6a87bb04925775bb2fd68c063152512e033313))
* check if ripgrep is available and show error if not ([b5cdae7](https://github.com/folke/todo-comments.nvim/commit/b5cdae78f58ac23fcf4340013e4dc7197881196a))
* expose methods to jump to next/prev todo comment ([89ee420](https://github.com/folke/todo-comments.nvim/commit/89ee420be60750d074bcb95efa6f2159c0671950))
* Group search and highlight options ([fbf91af](https://github.com/folke/todo-comments.nvim/commit/fbf91af72193987e50e542c5148ffcca2ff89050))
* Improve rg and highlight pattern matching ([7a00efb](https://github.com/folke/todo-comments.nvim/commit/7a00efb6a6c585303d333b0c543c640aa888fb83))
* inital version ([7473917](https://github.com/folke/todo-comments.nvim/commit/747391791bbb67fafeb2e690f4688720392470c8))
* intergration with lsp trouble ([194e653](https://github.com/folke/todo-comments.nvim/commit/194e65323bb1e3d35075d7b3451db697f1ba75f8))
* make it possible to disable warnings when searching ([#63](https://github.com/folke/todo-comments.nvim/issues/63)) ([9983edc](https://github.com/folke/todo-comments.nvim/commit/9983edc5ef38c7a035c17c85f60ee13dbd75dcc8))
* make sign priority configurable ([edbe161](https://github.com/folke/todo-comments.nvim/commit/edbe161856eacc859987eaf28d41b67163d49791))
* multiline todo comments ([8dffc5d](https://github.com/folke/todo-comments.nvim/commit/8dffc5d3ed1495e70c05f5ca1d100f8d3a4c44aa))
* quickfix, telescope and trouble commands ([a7c12f2](https://github.com/folke/todo-comments.nvim/commit/a7c12f288c995a738688ec3a42e6a1f6d48f3b89))
* set default multiline pattern to `^.` ([8f00cdb](https://github.com/folke/todo-comments.nvim/commit/8f00cdbbeafdad95dc1da0d846d21d9eef2d510b))
* Telescope plugin ([95f04b1](https://github.com/folke/todo-comments.nvim/commit/95f04b1a1fc9b7a17731eebde4353697c5a01f9b))
* todo-comments now requires Neovim &gt;= 0.8.0. Use the `neovim-pre-0.8.0` branch for older versions ([916cd4f](https://github.com/folke/todo-comments.nvim/commit/916cd4f144e7211874082286f7d5889018b5739d))
* use flame icon for hacks ([745df54](https://github.com/folke/todo-comments.nvim/commit/745df540153b0fc18b1ffec02c8875be1bf9e0c7))
* use treesitter to highlight keywords in comments only. If not a TS buffer, then highlight all comments [#22](https://github.com/folke/todo-comments.nvim/issues/22) ([b3fbe23](https://github.com/folke/todo-comments.nvim/commit/b3fbe23185189ba20ee0012bfbbb14e8fa55406e))
* use vim.notify instead of echo ([b745d75](https://github.com/folke/todo-comments.nvim/commit/b745d7513207eb8d809e1a92fae76e643310bf91))
* use vim.treesitter.get_captures_at_pos to detect comments ([6120afa](https://github.com/folke/todo-comments.nvim/commit/6120afa159d1dd3ba112ee4360b4ab4562a9b266))


### Bug Fixes

* add . to args for ripgrep to make it work on Windows ([03fc95a](https://github.com/folke/todo-comments.nvim/commit/03fc95a8f49edc8533a70577dedc44972733d88d))
* add proper error logging when ripgrep fails ([358b8c9](https://github.com/folke/todo-comments.nvim/commit/358b8c9c387557d21cbc14f8269e229467487954))
* allow highlighting in quickfix buffers ([f4d35a2](https://github.com/folke/todo-comments.nvim/commit/f4d35a2e5b601385b299bb44b1f556956d286292))
* avoid E5108 after pressing q: ([#111](https://github.com/folke/todo-comments.nvim/issues/111)) ([fb6f16b](https://github.com/folke/todo-comments.nvim/commit/fb6f16b89e475676d45bf6b39077fb752521e6f1))
* better keyword highlight pattern ([52d814d](https://github.com/folke/todo-comments.nvim/commit/52d814d7b5234e353d7599f566b1125d256633b9))
* check if buf is valid before clearing todo namespace ([23dfdaf](https://github.com/folke/todo-comments.nvim/commit/23dfdafe1990ae7b6c0f0c69a02736bb1a839219))
* check is current_win is still valid before setting it again ([37e7347](https://github.com/folke/todo-comments.nvim/commit/37e73472656d0642224dc86d9ce4784d8e4f5b5c))
* clear namespace with pcall to fix lazy loading weirdness. Fixes [#130](https://github.com/folke/todo-comments.nvim/issues/130) ([f990cd9](https://github.com/folke/todo-comments.nvim/commit/f990cd9c1d3e701f6746b523b71784ec2498ae35))
* debug code ([b09c700](https://github.com/folke/todo-comments.nvim/commit/b09c700ecf878092e91ed4b041c6eb7c840df994))
* defer highlight updates to prevent weird behavior of treesitter ([a4e433e](https://github.com/folke/todo-comments.nvim/commit/a4e433ee690455f94b4fba8fbc3241d061dc90f3))
* dont show signs for multiline comments ([3fe59db](https://github.com/folke/todo-comments.nvim/commit/3fe59db6dd6fb07857e0b9670a3b711104dfb53a))
* escape special characters in commentstring ([5fd5086](https://github.com/folke/todo-comments.nvim/commit/5fd5086a50f8bc012f50858805080c79ccb204bf))
* exit when buffer no longer exists ([3bc3bce](https://github.com/folke/todo-comments.nvim/commit/3bc3bceb4f1122028891830b2b408cd570e21859))
* fall back to syntax Comment if treesitter is not available ([b4dec37](https://github.com/folke/todo-comments.nvim/commit/b4dec37ba24c6c31d8129f601ff5db6cb4b9c99a))
* if todo is lazyloaded, then skip VimEnter ([564dc45](https://github.com/folke/todo-comments.nvim/commit/564dc4564cd47854f36e09e3d1910acb7e41e67d))
* improved comment support with treesitter ([219bc7e](https://github.com/folke/todo-comments.nvim/commit/219bc7ef4439b6fa53bc9db1dd14b11221e83d7d))
* is_comment now checks highlighter TS queries instead of parse tree ([d5f9bfc](https://github.com/folke/todo-comments.nvim/commit/d5f9bfc164c7ea306710d1a0a9d2db255387b1db))
* is_comment. Fixes [#145](https://github.com/folke/todo-comments.nvim/issues/145) ([1814fec](https://github.com/folke/todo-comments.nvim/commit/1814feca54540497de99d474dd6c9de6b691cf01))
* jumping to todo comments didnt use the correct line for is_comment checks ([c8c5446](https://github.com/folke/todo-comments.nvim/commit/c8c54465c74761ec95399584ed670700849ae401))
* keep previous options from setup ([8560546](https://github.com/folke/todo-comments.nvim/commit/8560546c466d1f555573d37e062e95e7ae94bbab))
* listen to treesitter changes to redo highlights ([9b276eb](https://github.com/folke/todo-comments.nvim/commit/9b276ebeeced9e15707c27e0b2588e7b3e19d9c5))
* matchstr fails with error about passing a dictionary as a string when string is binary [#23](https://github.com/folke/todo-comments.nvim/issues/23) ([ca2b794](https://github.com/folke/todo-comments.nvim/commit/ca2b7945e9bb58a5a8ab341b269028dd05d7ec61))
* never use comments to highlight quickfix buffers ([7a5e9c9](https://github.com/folke/todo-comments.nvim/commit/7a5e9c991670a834ed29951e58d29551f7a73fe3))
* pass kw start to is_comment. Fixes [#153](https://github.com/folke/todo-comments.nvim/issues/153) ([d3c6ec6](https://github.com/folke/todo-comments.nvim/commit/d3c6ec66caa07a31a16d3ed4b954a88742daa909))
* properly clear todo highlights in stop ([98b1ebf](https://github.com/folke/todo-comments.nvim/commit/98b1ebf198836bdc226c0562b9f906584e6c400e))
* properly escape commentstring [#19](https://github.com/folke/todo-comments.nvim/issues/19) ([a5c255c](https://github.com/folke/todo-comments.nvim/commit/a5c255c6860ae9456f339dc35586a6d47b6fd2cf))
* Properly pass options into jump function ([#143](https://github.com/folke/todo-comments.nvim/issues/143)) ([96391ae](https://github.com/folke/todo-comments.nvim/commit/96391ae41e63a5edba260adfd7312462b54ddc8e))
* re-apply highlights when treesitter bytes changes. Fixes [#134](https://github.com/folke/todo-comments.nvim/issues/134) ([e90b17e](https://github.com/folke/todo-comments.nvim/commit/e90b17e45c39f6f37994a2f0f60dde8472b8457d))
* remove FIX from alts for FIX ([e3b96b2](https://github.com/folke/todo-comments.nvim/commit/e3b96b253150c217a603fa11b79b90fcb2d1a649))
* remove set_current_win ([d2b9b26](https://github.com/folke/todo-comments.nvim/commit/d2b9b265ae250ac3c1737180095352080059d212))
* revert extmarks to add_highlight ([4a27e05](https://github.com/folke/todo-comments.nvim/commit/4a27e05519827ba1594d5ce3fde874040f005bfe))
* ripgrep gives exit code 2 on error. Exit code 1 means no results ([3ad4967](https://github.com/folke/todo-comments.nvim/commit/3ad4967972ed463ce1dfd38161ea98862b2bdffa))
* set fg_dark and fg_light to black and white for colorschemes that dont set Normal ([b64859a](https://github.com/folke/todo-comments.nvim/commit/b64859a2313472284fb0d29d9bc9e0108725ecc4))
* show error when running Todo without doing setup() ([f0cc7d3](https://github.com/folke/todo-comments.nvim/commit/f0cc7d3eb7c017c87c1ef52bf3f51d292971ef29))
* show warning message when no results were found ([09aa8de](https://github.com/folke/todo-comments.nvim/commit/09aa8de5ddb2483cafb955645bb4f98701736a98))
* skip possibly bad regex results ([014959e](https://github.com/folke/todo-comments.nvim/commit/014959e82aabc07a16739c771bf40e7fd6de3fe9))
* sort keywords by length in descending order ([#157](https://github.com/folke/todo-comments.nvim/issues/157)) ([2adb83e](https://github.com/folke/todo-comments.nvim/commit/2adb83e0fb082a5f1c40f3def4c8b18ec767c5ee))
* todo comments was broken for non treesitter files. Fixes [#150](https://github.com/folke/todo-comments.nvim/issues/150) ([f244aa3](https://github.com/folke/todo-comments.nvim/commit/f244aa391774b29878db580eff63a9e26dc5f084))
* Update docs ([2273076](https://github.com/folke/todo-comments.nvim/commit/2273076591b9ce78f562b52e3c0b4e34102f54a5))
* update README to 0.6 diagnostic hl ([#78](https://github.com/folke/todo-comments.nvim/issues/78)) ([672cd22](https://github.com/folke/todo-comments.nvim/commit/672cd22bd15928434374ac52d0cf38dd250231df))
* updated default colors to use 0.6 diagnostic highlights ([6570fd2](https://github.com/folke/todo-comments.nvim/commit/6570fd271d17fec1966522f3a19cc6f4c88824c4))
* use nvim_win_call instead of changing current window to apply highlights ([bff9e31](https://github.com/folke/todo-comments.nvim/commit/bff9e315ac3b5854a08d5a73b898822bdec1a5c3))
* use options.search.command for telescope ([ed24570](https://github.com/folke/todo-comments.nvim/commit/ed24570d07e0ffae9969006009a91ecabfff1493))
* use seperate hl group for signs using correct SignColumn bg color ([bf138df](https://github.com/folke/todo-comments.nvim/commit/bf138dff36602a1da40bbebabef8bae61735635c))
* use white as fg for color schemes that dont define a fg for Normal ([ec820ad](https://github.com/folke/todo-comments.nvim/commit/ec820ade091c28b221eb2f6d0ee02c554a61a8e8))
* When todo-comments.nvim as optional and report an error the first time you use it. ([#129](https://github.com/folke/todo-comments.nvim/issues/129)) ([5f90941](https://github.com/folke/todo-comments.nvim/commit/5f9094198563b693439837b593815dc18768fda8))


### Performance Improvements

* defer settings up todo-comments ([5e84162](https://github.com/folke/todo-comments.nvim/commit/5e8416265a23c8b8b4711be73b465e6f6566f49b))
* defer setup to BufReadPre ++once ([455f49e](https://github.com/folke/todo-comments.nvim/commit/455f49e6e263fdd2fe1bfff2b1eb7c7457fbf68f))
* redraw was always doing the whole file! Fixes [#155](https://github.com/folke/todo-comments.nvim/issues/155) ([bca0e00](https://github.com/folke/todo-comments.nvim/commit/bca0e00644c22a3eecedce703c0db080dd6bdc55))
* throttle todo redraw calls. Fixes [#154](https://github.com/folke/todo-comments.nvim/issues/154) ([a9df434](https://github.com/folke/todo-comments.nvim/commit/a9df4342a564e9d95340f60a38a523fda27cdb2e))

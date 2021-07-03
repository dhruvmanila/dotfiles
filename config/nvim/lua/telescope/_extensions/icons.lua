local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  vim.notify("[Telescope] `icons` extension requires telescope.nvim", 4)
end

local nr2char = vim.fn.nr2char
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local config = require("telescope.config").values
local entry_display = require "telescope.pickers.entry_display"
local themes = require "telescope.themes"

local max_length = 0

-- https://raw.githubusercontent.com/microsoft/vscode-codicons/main/src/template/mapping.json
local codicons = { -- {{{
  ["add"] = 60000,
  ["plus"] = 60000,
  ["gist-new"] = 60000,
  ["repo-create"] = 60000,
  ["lightbulb"] = 60001,
  ["light-bulb"] = 60001,
  ["repo"] = 60002,
  ["repo-delete"] = 60002,
  ["gist-fork"] = 60003,
  ["repo-forked"] = 60003,
  ["git-pull-request"] = 60004,
  ["git-pull-request-abandoned"] = 60004,
  ["record-keys"] = 60005,
  ["keyboard"] = 60005,
  ["tag"] = 60006,
  ["tag-add"] = 60006,
  ["tag-remove"] = 60006,
  ["person"] = 60007,
  ["person-follow"] = 60007,
  ["person-outline"] = 60007,
  ["person-filled"] = 60007,
  ["git-branch"] = 60008,
  ["git-branch-create"] = 60008,
  ["git-branch-delete"] = 60008,
  ["source-control"] = 60008,
  ["mirror"] = 60009,
  ["mirror-public"] = 60009,
  ["star"] = 60010,
  ["star-add"] = 60010,
  ["star-delete"] = 60010,
  ["star-empty"] = 60010,
  ["comment"] = 60011,
  ["comment-add"] = 60011,
  ["alert"] = 60012,
  ["warning"] = 60012,
  ["search"] = 60013,
  ["search-save"] = 60013,
  ["log-out"] = 60014,
  ["sign-out"] = 60014,
  ["log-in"] = 60015,
  ["sign-in"] = 60015,
  ["eye"] = 60016,
  ["eye-unwatch"] = 60016,
  ["eye-watch"] = 60016,
  ["circle-filled"] = 60017,
  ["primitive-dot"] = 60017,
  ["close-dirty"] = 60017,
  ["debug-breakpoint"] = 60017,
  ["debug-breakpoint-disabled"] = 60017,
  ["debug-hint"] = 60017,
  ["primitive-square"] = 60018,
  ["edit"] = 60019,
  ["pencil"] = 60019,
  ["info"] = 60020,
  ["issue-opened"] = 60020,
  ["gist-private"] = 60021,
  ["git-fork-private"] = 60021,
  ["lock"] = 60021,
  ["mirror-private"] = 60021,
  ["close"] = 60022,
  ["remove-close"] = 60022,
  ["x"] = 60022,
  ["repo-sync"] = 60023,
  ["sync"] = 60023,
  ["clone"] = 60024,
  ["desktop-download"] = 60024,
  ["beaker"] = 60025,
  ["microscope"] = 60025,
  ["vm"] = 60026,
  ["device-desktop"] = 60026,
  ["file"] = 60027,
  ["file-text"] = 60027,
  ["more"] = 60028,
  ["ellipsis"] = 60028,
  ["kebab-horizontal"] = 60028,
  ["mail-reply"] = 60029,
  ["reply"] = 60029,
  ["organization"] = 60030,
  ["organization-filled"] = 60030,
  ["organization-outline"] = 60030,
  ["new-file"] = 60031,
  ["file-add"] = 60031,
  ["new-folder"] = 60032,
  ["file-directory-create"] = 60032,
  ["trash"] = 60033,
  ["trashcan"] = 60033,
  ["history"] = 60034,
  ["clock"] = 60034,
  ["folder"] = 60035,
  ["file-directory"] = 60035,
  ["symbol-folder"] = 60035,
  ["logo-github"] = 60036,
  ["mark-github"] = 60036,
  ["github"] = 60036,
  ["terminal"] = 60037,
  ["console"] = 60037,
  ["repl"] = 60037,
  ["zap"] = 60038,
  ["symbol-event"] = 60038,
  ["error"] = 60039,
  ["stop"] = 60039,
  ["variable"] = 60040,
  ["symbol-variable"] = 60040,
  ["array"] = 60042,
  ["symbol-array"] = 60042,
  ["symbol-module"] = 60043,
  ["symbol-package"] = 60043,
  ["symbol-namespace"] = 60043,
  ["symbol-object"] = 60043,
  ["symbol-method"] = 60044,
  ["symbol-function"] = 60044,
  ["symbol-constructor"] = 60044,
  ["symbol-boolean"] = 60047,
  ["symbol-null"] = 60047,
  ["symbol-numeric"] = 60048,
  ["symbol-number"] = 60048,
  ["symbol-structure"] = 60049,
  ["symbol-struct"] = 60049,
  ["symbol-parameter"] = 60050,
  ["symbol-type-parameter"] = 60050,
  ["symbol-key"] = 60051,
  ["symbol-text"] = 60051,
  ["symbol-reference"] = 60052,
  ["go-to-file"] = 60052,
  ["symbol-enum"] = 60053,
  ["symbol-value"] = 60053,
  ["symbol-ruler"] = 60054,
  ["symbol-unit"] = 60054,
  ["activate-breakpoints"] = 60055,
  ["archive"] = 60056,
  ["arrow-both"] = 60057,
  ["arrow-down"] = 60058,
  ["arrow-left"] = 60059,
  ["arrow-right"] = 60060,
  ["arrow-small-down"] = 60061,
  ["arrow-small-left"] = 60062,
  ["arrow-small-right"] = 60063,
  ["arrow-small-up"] = 60064,
  ["arrow-up"] = 60065,
  ["bell"] = 60066,
  ["bold"] = 60067,
  ["book"] = 60068,
  ["bookmark"] = 60069,
  ["debug-breakpoint-conditional-unverified"] = 60070,
  ["debug-breakpoint-conditional"] = 60071,
  ["debug-breakpoint-conditional-disabled"] = 60071,
  ["debug-breakpoint-data-unverified"] = 60072,
  ["debug-breakpoint-data"] = 60073,
  ["debug-breakpoint-data-disabled"] = 60073,
  ["debug-breakpoint-log-unverified"] = 60074,
  ["debug-breakpoint-log"] = 60075,
  ["debug-breakpoint-log-disabled"] = 60075,
  ["briefcase"] = 60076,
  ["broadcast"] = 60077,
  ["browser"] = 60078,
  ["bug"] = 60079,
  ["calendar"] = 60080,
  ["case-sensitive"] = 60081,
  ["check"] = 60082,
  ["checklist"] = 60083,
  ["chevron-down"] = 60084,
  ["chevron-left"] = 60085,
  ["chevron-right"] = 60086,
  ["chevron-up"] = 60087,
  ["chrome-close"] = 60088,
  ["chrome-maximize"] = 60089,
  ["chrome-minimize"] = 60090,
  ["chrome-restore"] = 60091,
  ["circle-outline"] = 60092,
  ["debug-breakpoint-unverified"] = 60092,
  ["circle-slash"] = 60093,
  ["circuit-board"] = 60094,
  ["clear-all"] = 60095,
  ["clippy"] = 60096,
  ["close-all"] = 60097,
  ["cloud-download"] = 60098,
  ["cloud-upload"] = 60099,
  ["code"] = 60100,
  ["collapse-all"] = 60101,
  ["color-mode"] = 60102,
  ["comment-discussion"] = 60103,
  ["credit-card"] = 60105,
  ["dash"] = 60108,
  ["dashboard"] = 60109,
  ["database"] = 60110,
  ["debug-continue"] = 60111,
  ["debug-disconnect"] = 60112,
  ["debug-pause"] = 60113,
  ["debug-restart"] = 60114,
  ["debug-start"] = 60115,
  ["debug-step-into"] = 60116,
  ["debug-step-out"] = 60117,
  ["debug-step-over"] = 60118,
  ["debug-stop"] = 60119,
  ["debug"] = 60120,
  ["device-camera-video"] = 60121,
  ["device-camera"] = 60122,
  ["device-mobile"] = 60123,
  ["diff-added"] = 60124,
  ["diff-ignored"] = 60125,
  ["diff-modified"] = 60126,
  ["diff-removed"] = 60127,
  ["diff-renamed"] = 60128,
  ["diff"] = 60129,
  ["discard"] = 60130,
  ["editor-layout"] = 60131,
  ["empty-window"] = 60132,
  ["exclude"] = 60133,
  ["extensions"] = 60134,
  ["eye-closed"] = 60135,
  ["file-binary"] = 60136,
  ["file-code"] = 60137,
  ["file-media"] = 60138,
  ["file-pdf"] = 60139,
  ["file-submodule"] = 60140,
  ["file-symlink-directory"] = 60141,
  ["file-symlink-file"] = 60142,
  ["file-zip"] = 60143,
  ["files"] = 60144,
  ["filter"] = 60145,
  ["flame"] = 60146,
  ["fold-down"] = 60147,
  ["fold-up"] = 60148,
  ["fold"] = 60149,
  ["folder-active"] = 60150,
  ["folder-opened"] = 60151,
  ["gear"] = 60152,
  ["gift"] = 60153,
  ["gist-secret"] = 60154,
  ["gist"] = 60155,
  ["git-commit"] = 60156,
  ["git-compare"] = 60157,
  ["compare-changes"] = 60157,
  ["git-merge"] = 60158,
  ["github-action"] = 60159,
  ["github-alt"] = 60160,
  ["globe"] = 60161,
  ["grabber"] = 60162,
  ["graph"] = 60163,
  ["gripper"] = 60164,
  ["heart"] = 60165,
  ["home"] = 60166,
  ["horizontal-rule"] = 60167,
  ["hubot"] = 60168,
  ["inbox"] = 60169,
  ["issue-closed"] = 60170,
  ["issue-reopened"] = 60171,
  ["issues"] = 60172,
  ["italic"] = 60173,
  ["jersey"] = 60174,
  ["json"] = 60175,
  ["kebab-vertical"] = 60176,
  ["key"] = 60177,
  ["law"] = 60178,
  ["lightbulb-autofix"] = 60179,
  ["link-external"] = 60180,
  ["link"] = 60181,
  ["list-ordered"] = 60182,
  ["list-unordered"] = 60183,
  ["live-share"] = 60184,
  ["loading"] = 60185,
  ["location"] = 60186,
  ["mail-read"] = 60187,
  ["mail"] = 60188,
  ["markdown"] = 60189,
  ["megaphone"] = 60190,
  ["mention"] = 60191,
  ["milestone"] = 60192,
  ["mortar-board"] = 60193,
  ["move"] = 60194,
  ["multiple-windows"] = 60195,
  ["mute"] = 60196,
  ["no-newline"] = 60197,
  ["note"] = 60198,
  ["octoface"] = 60199,
  ["open-preview"] = 60200,
  ["package"] = 60201,
  ["paintcan"] = 60202,
  ["pin"] = 60203,
  ["play"] = 60204,
  ["run"] = 60204,
  ["plug"] = 60205,
  ["preserve-case"] = 60206,
  ["preview"] = 60207,
  ["project"] = 60208,
  ["pulse"] = 60209,
  ["question"] = 60210,
  ["quote"] = 60211,
  ["radio-tower"] = 60212,
  ["reactions"] = 60213,
  ["references"] = 60214,
  ["refresh"] = 60215,
  ["regex"] = 60216,
  ["remote-explorer"] = 60217,
  ["remote"] = 60218,
  ["remove"] = 60219,
  ["replace-all"] = 60220,
  ["replace"] = 60221,
  ["repo-clone"] = 60222,
  ["repo-force-push"] = 60223,
  ["repo-pull"] = 60224,
  ["repo-push"] = 60225,
  ["report"] = 60226,
  ["request-changes"] = 60227,
  ["rocket"] = 60228,
  ["root-folder-opened"] = 60229,
  ["root-folder"] = 60230,
  ["rss"] = 60231,
  ["ruby"] = 60232,
  ["save-all"] = 60233,
  ["save-as"] = 60234,
  ["save"] = 60235,
  ["screen-full"] = 60236,
  ["screen-normal"] = 60237,
  ["search-stop"] = 60238,
  ["server"] = 60240,
  ["settings-gear"] = 60241,
  ["settings"] = 60242,
  ["shield"] = 60243,
  ["smiley"] = 60244,
  ["sort-precedence"] = 60245,
  ["split-horizontal"] = 60246,
  ["split-vertical"] = 60247,
  ["squirrel"] = 60248,
  ["star-full"] = 60249,
  ["star-half"] = 60250,
  ["symbol-class"] = 60251,
  ["symbol-color"] = 60252,
  ["symbol-constant"] = 60253,
  ["symbol-enum-member"] = 60254,
  ["symbol-field"] = 60255,
  ["symbol-file"] = 60256,
  ["symbol-interface"] = 60257,
  ["symbol-keyword"] = 60258,
  ["symbol-misc"] = 60259,
  ["symbol-operator"] = 60260,
  ["symbol-property"] = 60261,
  ["wrench"] = 60261,
  ["wrench-subaction"] = 60261,
  ["symbol-snippet"] = 60262,
  ["tasklist"] = 60263,
  ["telescope"] = 60264,
  ["text-size"] = 60265,
  ["three-bars"] = 60266,
  ["thumbsdown"] = 60267,
  ["thumbsup"] = 60268,
  ["tools"] = 60269,
  ["triangle-down"] = 60270,
  ["triangle-left"] = 60271,
  ["triangle-right"] = 60272,
  ["triangle-up"] = 60273,
  ["twitter"] = 60274,
  ["unfold"] = 60275,
  ["unlock"] = 60276,
  ["unmute"] = 60277,
  ["unverified"] = 60278,
  ["verified"] = 60279,
  ["versions"] = 60280,
  ["vm-active"] = 60281,
  ["vm-outline"] = 60282,
  ["vm-running"] = 60283,
  ["watch"] = 60284,
  ["whitespace"] = 60285,
  ["whole-word"] = 60286,
  ["window"] = 60287,
  ["word-wrap"] = 60288,
  ["zoom-in"] = 60289,
  ["zoom-out"] = 60290,
  ["list-filter"] = 60291,
  ["list-flat"] = 60292,
  ["list-selection"] = 60293,
  ["selection"] = 60293,
  ["list-tree"] = 60294,
  ["debug-breakpoint-function-unverified"] = 60295,
  ["debug-breakpoint-function"] = 60296,
  ["debug-breakpoint-function-disabled"] = 60296,
  ["debug-stackframe-active"] = 60297,
  ["debug-stackframe-dot"] = 60298,
  ["debug-stackframe"] = 60299,
  ["debug-stackframe-focused"] = 60299,
  ["debug-breakpoint-unsupported"] = 60300,
  ["symbol-string"] = 60301,
  ["debug-reverse-continue"] = 60302,
  ["debug-step-back"] = 60303,
  ["debug-restart-frame"] = 60304,
  ["debug-alt"] = 60305,
  ["call-incoming"] = 60306,
  ["call-outgoing"] = 60307,
  ["menu"] = 60308,
  ["expand-all"] = 60309,
  ["feedback"] = 60310,
  ["group-by-ref-type"] = 60311,
  ["ungroup-by-ref-type"] = 60312,
  ["account"] = 60313,
  ["bell-dot"] = 60314,
  ["debug-console"] = 60315,
  ["library"] = 60316,
  ["output"] = 60317,
  ["run-all"] = 60318,
  ["sync-ignored"] = 60319,
  ["pinned"] = 60320,
  ["github-inverted"] = 60321,
  ["server-process"] = 60322,
  ["server-environment"] = 60323,
  ["pass"] = 60324,
  ["stop-circle"] = 60325,
  ["play-circle"] = 60326,
  ["record"] = 60327,
  ["debug-alt-small"] = 60328,
  ["vm-connect"] = 60329,
  ["cloud"] = 60330,
  ["merge"] = 60331,
  ["export"] = 60332,
  ["graph-left"] = 60333,
  ["magnet"] = 60334,
  ["notebook"] = 60335,
  ["redo"] = 60336,
  ["check-all"] = 60337,
  ["pinned-dirty"] = 60338,
  ["pass-filled"] = 60339,
  ["circle-large-filled"] = 60340,
  ["circle-large-outline"] = 60341,
  ["combine"] = 60342,
  ["gather"] = 60342,
  ["table"] = 60343,
  ["variable-group"] = 60344,
  ["type-hierarchy"] = 60345,
  ["type-hierarchy-sub"] = 60346,
  ["type-hierarchy-super"] = 60347,
  ["git-pull-request-create"] = 60348,
  ["run-above"] = 60349,
  ["run-below"] = 60350,
  ["notebook-template"] = 60351,
  ["debug-rerun"] = 60352,
  ["workspace-trusted"] = 60353,
  ["workspace-untrusted"] = 60354,
  ["workspace-unknown"] = 60355,
  ["terminal-cmd"] = 60356,
  ["terminal-debian"] = 60357,
  ["terminal-linux"] = 60358,
  ["terminal-powershell"] = 60359,
  ["terminal-tmux"] = 60360,
  ["terminal-ubuntu"] = 60361,
  ["terminal-bash"] = 60362,
  ["arrow-swap"] = 60363,
  ["copy"] = 60364,
  ["person-add"] = 60365,
  ["filter-filled"] = 60366,
  ["wand"] = 60367,
  ["debug-line-by-line"] = 60368,
  ["inspect"] = 60369,
}
-- }}}
-- https://github.com/yamatsum/nvim-nonicons/blob/main/lua/nvim-nonicons/mapping.lua
local nonicons = { -- {{{
  ["alert"] = "61697",
  ["angular"] = "61698",
  ["archive"] = "61699",
  ["arrow-both"] = "61700",
  ["arrow-down"] = "61701",
  ["arrow-left"] = "61702",
  ["arrow-right"] = "61703",
  ["arrow-switch"] = "61704",
  ["arrow-up"] = "61705",
  ["backbone"] = "61706",
  ["beaker"] = "61707",
  ["bell"] = "61708",
  ["bell-slash"] = "61709",
  ["bold"] = "61710",
  ["book"] = "61711",
  ["bookmark"] = "61712",
  ["bookmark-slash"] = "61713",
  ["briefcase"] = "61714",
  ["broadcast"] = "61715",
  ["browser"] = "61716",
  ["bug"] = "61717",
  ["c"] = "61718",
  ["c-plusplus"] = "61719",
  ["c-sharp"] = "61720",
  ["calendar"] = "61721",
  ["check"] = "61722",
  ["check-circle"] = "61723",
  ["check-circle-fill"] = "61724",
  ["checklist"] = "61725",
  ["chevron-down"] = "61726",
  ["chevron-left"] = "61727",
  ["chevron-right"] = "61728",
  ["chevron-up"] = "61729",
  ["circle"] = "61730",
  ["circle-slash"] = "61731",
  ["clippy"] = "61732",
  ["clock"] = "61733",
  ["code"] = "61734",
  ["code-review"] = "61735",
  ["code-square"] = "61736",
  ["comment"] = "61737",
  ["comment-discussion"] = "61738",
  ["container"] = "61739",
  ["cpu"] = "61740",
  ["credit-card"] = "61741",
  ["cross-reference"] = "61742",
  ["css"] = "61743",
  ["dart"] = "61744",
  ["dash"] = "61745",
  ["database"] = "61746",
  ["desktop-download"] = "61747",
  ["device-camera"] = "61748",
  ["device-camera-video"] = "61749",
  ["device-desktop"] = "61750",
  ["device-mobile"] = "61751",
  ["diff"] = "61752",
  ["diff-added"] = "61753",
  ["diff-ignored"] = "61754",
  ["diff-modified"] = "61755",
  ["diff-removed"] = "61756",
  ["diff-renamed"] = "61757",
  ["docker"] = "61758",
  ["dot"] = "61759",
  ["dot-fill"] = "61760",
  ["download"] = "61761",
  ["ellipsis"] = "61762",
  ["elm"] = "61763",
  ["eye"] = "61764",
  ["eye-closed"] = "61765",
  ["file"] = "61766",
  ["file-badge"] = "61767",
  ["file-binary"] = "61768",
  ["file-code"] = "61769",
  ["file-diff"] = "61770",
  ["file-directory"] = "61771",
  ["file-directory-outline"] = "61772",
  ["file-submodule"] = "61773",
  ["file-symlink-file"] = "61774",
  ["file-zip"] = "61775",
  ["filter"] = "61776",
  ["flame"] = "61777",
  ["fold"] = "61778",
  ["fold-down"] = "61779",
  ["fold-up"] = "61780",
  ["gear"] = "61781",
  ["gift"] = "61782",
  ["git-branch"] = "61783",
  ["git-commit"] = "61784",
  ["git-compare"] = "61785",
  ["git-merge"] = "61786",
  ["git-pull-request"] = "61787",
  ["globe"] = "61788",
  ["go"] = "61789",
  ["grabber"] = "61790",
  ["graph"] = "61791",
  ["heading"] = "61792",
  ["heart"] = "61793",
  ["heart-fill"] = "61794",
  ["history"] = "61795",
  ["home"] = "61796",
  ["horizontal-rule"] = "61797",
  ["hourglass"] = "61798",
  ["html"] = "61799",
  ["hubot"] = "61800",
  ["image"] = "61801",
  ["inbox"] = "61802",
  ["infinity"] = "61803",
  ["info"] = "61804",
  ["issue-closed"] = "61805",
  ["issue-opened"] = "61806",
  ["issue-reopened"] = "61807",
  ["italic"] = "61808",
  ["java"] = "61809",
  ["javascript"] = "61810",
  ["json"] = "61811",
  ["kebab-horizontal"] = "61812",
  ["key"] = "61813",
  ["kotlin"] = "61814",
  ["kubernetes"] = "61815",
  ["law"] = "61816",
  ["light-bulb"] = "61817",
  ["link"] = "61818",
  ["link-external"] = "61819",
  ["list-ordered"] = "61820",
  ["list-unordered"] = "61821",
  ["location"] = "61822",
  ["lock"] = "61823",
  ["logo-gist"] = "61824",
  ["logo-github"] = "61825",
  ["lua"] = "61826",
  ["mail"] = "61827",
  ["mark-github"] = "61828",
  ["markdown"] = "61829",
  ["megaphone"] = "61830",
  ["mention"] = "61831",
  ["meter"] = "61832",
  ["milestone"] = "61833",
  ["mirror"] = "61834",
  ["moon"] = "61835",
  ["mortar-board"] = "61836",
  ["mute"] = "61837",
  ["nginx"] = "61838",
  ["no-entry"] = "61839",
  ["node"] = "61840",
  ["north-star"] = "61841",
  ["note"] = "61842",
  ["npm"] = "61843",
  ["octoface"] = "61844",
  ["organization"] = "61845",
  ["package"] = "61846",
  ["package-dependencies"] = "61847",
  ["package-dependents"] = "61848",
  ["paintbrush"] = "61849",
  ["paper-airplane"] = "61850",
  ["pencil"] = "61851",
  ["people"] = "61852",
  ["perl"] = "61853",
  ["person"] = "61854",
  ["php"] = "61855",
  ["pin"] = "61856",
  ["play"] = "61857",
  ["plug"] = "61858",
  ["plus"] = "61859",
  ["plus-circle"] = "61860",
  ["project"] = "61861",
  ["pulse"] = "61862",
  ["python"] = "61863",
  ["question"] = "61864",
  ["quote"] = "61865",
  ["r"] = "61866",
  ["react"] = "61867",
  ["rectangle"] = "61868",
  ["reply"] = "61869",
  ["repo"] = "61870",
  ["repo-clone"] = "61871",
  ["repo-forked"] = "61872",
  ["repo-pull"] = "61873",
  ["repo-push"] = "61874",
  ["repo-template"] = "61875",
  ["report"] = "61876",
  ["require"] = "61877",
  ["rocket"] = "61878",
  ["rss"] = "61879",
  ["ruby"] = "61880",
  ["rust"] = "61881",
  ["scala"] = "61882",
  ["screen-full"] = "61883",
  ["screen-normal"] = "61884",
  ["search"] = "61885",
  ["server"] = "61886",
  ["share"] = "61887",
  ["share-android"] = "61888",
  ["shield"] = "61889",
  ["shield-check"] = "61890",
  ["shield-lock"] = "61891",
  ["shield-x"] = "61892",
  ["sign-in"] = "61893",
  ["sign-out"] = "61894",
  ["skip"] = "61895",
  ["smiley"] = "61896",
  ["square"] = "61897",
  ["square-fill"] = "61898",
  ["squirrel"] = "61899",
  ["star"] = "61900",
  ["star-fill"] = "61901",
  ["stop"] = "61902",
  ["stopwatch"] = "61903",
  ["strikethrough"] = "61904",
  ["sun"] = "61905",
  ["swift"] = "61906",
  ["sync"] = "61907",
  ["tag"] = "61908",
  ["tasklist"] = "61909",
  ["telescope"] = "61910",
  ["terminal"] = "61911",
  ["three-bars"] = "61912",
  ["thumbsdown"] = "61913",
  ["thumbsup"] = "61914",
  ["tmux"] = "61915",
  ["toml"] = "61916",
  ["tools"] = "61917",
  ["trashcan"] = "61918",
  ["triangle-down"] = "61919",
  ["triangle-left"] = "61920",
  ["triangle-right"] = "61921",
  ["triangle-up"] = "61922",
  ["typescript"] = "61923",
  ["typography"] = "61924",
  ["unfold"] = "61925",
  ["unlock"] = "61926",
  ["unmute"] = "61927",
  ["unverified"] = "61928",
  ["upload"] = "61929",
  ["verified"] = "61930",
  ["versions"] = "61931",
  ["vim"] = "61932",
  ["vim-command-mode"] = "61933",
  ["vim-insert-mode"] = "61934",
  ["vim-normal-mode"] = "61935",
  ["vim-replace-mode"] = "61936",
  ["vim-select-mode"] = "61937",
  ["vim-terminal-mode"] = "61938",
  ["vim-visual-mode"] = "61939",
  ["vue"] = "61940",
  ["workflow"] = "61941",
  ["x"] = "61942",
  ["x-circle"] = "61943",
  ["x-circle-fill"] = "61944",
  ["yaml"] = "61945",
  ["yarn"] = "61946",
  ["zap"] = "61947",
  ["multi-select"] = "61948",
  ["number"] = "61949",
  ["trash"] = "61950",
  ["video"] = "61951",
  ["class"] = "61952",
  ["constant"] = "61953",
  ["field"] = "61954",
  ["interface"] = "61955",
  ["keyword"] = "61956",
  ["snippet"] = "61957",
  ["struct"] = "61958",
  ["type"] = "61959",
  ["variable"] = "61960",
}
-- }}}

-- Collect all the icons from the above codicons and nonicons table by
-- converting each entry to it's respective icon. The font `codicons` and
-- `nonicons` are required to be installed on the system.
---@return table
local function collect_icons()
  local icons = {}
  local mapping = vim.tbl_deep_extend("force", codicons, nonicons)
  local names = vim.tbl_keys(mapping)
  table.sort(names, function(x, y)
    return x < y
  end)
  for _, name in ipairs(names) do
    local length = #name
    max_length = math.max(length, max_length)
    table.insert(icons, { name = name, icon = nr2char(mapping[name]) })
  end
  return icons
end

-- This extension will display a list of icons from the codicons and nonicons
-- set and the user can copy the icon using `<C-y>`.
local function icons()
  local results = collect_icons()
  local opts = themes.get_dropdown {
    layout_config = {
      width = max_length + 8,
      height = 0.8,
    },
  }

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = max_length + 2 },
      { remaining = true },
    },
  }

  local function make_display(entry)
    return displayer { entry.name, entry.icon }
  end

  pickers.new(opts, {
    prompt_title = "Search Icons",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          display = make_display,
          value = entry.icon,
          name = entry.name,
          icon = entry.icon,
          ordinal = entry.name,
        }
      end,
    },
    previewer = false,
    sorter = config.generic_sorter(opts),
  }):find()
end

return telescope.register_extension {
  exports = { icons = icons },
}

-- vim: foldmethod=marker:

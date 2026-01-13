from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut


def should_pass_keys(window) -> bool:
    """Returns `True` if keys should be passed to the foreground process."""
    for process in window.child.foreground_processes:
        cmd = next(iter(process["cmdline"]), "")
        if cmd.endswith("nvim") or cmd.endswith("fzf"):
            return True
    return False


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()
    return window.encoded_key(event)


def main():
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    direction = args[1]
    key_mapping = args[2]
    if should_pass_keys(window):
        for keymap in key_mapping.split(">"):
            encoded = encode_key_mapping(window, keymap)
            window.write_to_child(encoded)
    else:
        boss.active_tab.neighboring_window(direction)

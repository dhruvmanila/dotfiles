"""
Resize the current window relative to its position.

Source: https://github.com/chancez/dotfiles/blob/eebc5a4693decba0ff078e133a642e2febc45bc9/kitty/.config/kitty/relative_resize.py
"""
from kittens.tui.handler import result_handler

INCREMENT = 2
VALID_DIRECTIONS = {"left", "right", "up", "down"}


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    direction = args[1]
    if direction not in VALID_DIRECTIONS:
        return

    neighbors = boss.active_tab.current_layout.neighbors_for_window(
        window, boss.active_tab.windows
    )

    left_neighbors = neighbors.get("left")
    right_neighbors = neighbors.get("right")
    top_neighbors = neighbors.get("top")
    bottom_neighbors = neighbors.get("bottom")

    # Has a neighbor on both sides
    if direction == "left" and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window("narrower", INCREMENT)

    # Only has left neighbor
    elif direction == "left" and left_neighbors:
        boss.active_tab.resize_window("wider", INCREMENT)

    # Only has right neighbor
    elif direction == "left" and right_neighbors:
        boss.active_tab.resize_window("narrower", INCREMENT)

    # Has a neighbor on both sides
    elif direction == "right" and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window("wider", INCREMENT)

    # Only has left neighbor
    elif direction == "right" and left_neighbors:
        boss.active_tab.resize_window("narrower", INCREMENT)

    # Only has right neighbor
    elif direction == "right" and right_neighbors:
        boss.active_tab.resize_window("wider", INCREMENT)

    # Has a neighbor above and below
    elif direction == "up" and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window("shorter", INCREMENT)

    # Only has top neighbor
    elif direction == "up" and top_neighbors:
        boss.active_tab.resize_window("taller", INCREMENT)

    # Only has bottom neighbor
    elif direction == "up" and bottom_neighbors:
        boss.active_tab.resize_window("shorter", INCREMENT)

    # Has a neighbor above and below
    elif direction == "down" and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window("taller", INCREMENT)

    # Only has top neighbor
    elif direction == "down" and top_neighbors:
        boss.active_tab.resize_window("shorter", INCREMENT)

    # Only has bottom neighbor
    elif direction == "down" and bottom_neighbors:
        boss.active_tab.resize_window("taller", INCREMENT)

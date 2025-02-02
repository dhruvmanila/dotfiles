from kittens.tui.handler import result_handler


def main(args):
    pass


directions = ["right", "left", "top", "bottom"]


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    print("navigate_kitty.py: ", args, result, target_window_id)
    if len(args) != 2:
        return
    direction = args[1]
    if direction in directions:
        boss.active_tab.neighboring_window(direction)

import day

def get_input(number: int | str) -> str:
    input_file = day.CUR_DIR / str(number) / "input"
    return input_file.read_text()

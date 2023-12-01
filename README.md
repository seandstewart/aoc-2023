# Advent of Code - 2023

This year, as last year, I will attempt to solve the given puzzles with a preference 
for leveraging native PostgeSQL, including pl/pgsql when necessary.

## Goals

1. Prefer SQL for solving every aspect, including parsing the input.
2. Prefer Python for glue code.
3. Test-driven development of SQL code.
4. Don't quit after day 4 :P

## Toolchain
- [sqitch][1]: Test-driven development of SQL migrations.
- [aoc-cli][2]: Simple CLI for downloading puzzles and submitting responses. (RIR 
  :crab:)
- [yesql][3]: SQL-first data-management library implementing the 
  [Repository Pattern][4].
- [typical][5]: Simple un/marshalling of Python data structures and types.
- [docker compose][6]: Containerized service orchestration.

[1]: https://sqitch.org/docs/
[2]: https://github.com/scarvalhojr/aoc-cli
[3]: https://github.com/seandstewart/yesql
[4]: https://www.cosmicpython.com/book/chapter_02_repository.html
[5]: https://github.com/seandstewart/typical
[6]: https://docs.docker.com/compose/

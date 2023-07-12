// ignore_for_file: prefer_const_constructors

import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bfs_visualizer/bloc/appbloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameLoadingState extends AppState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GameLoadedState extends AppState {
  int rows, cols;
  List<List<String>> grid;
  List<List<Color>> clr;
  bool play, start, end, block;
  GameLoadedState(this.play, this.start, this.end, this.block, this.grid,
      this.clr, this.rows, this.cols);

  @override
  List<Object> get props => [play, grid, clr];
}

class LoadGameEvent extends AppEvent {}

class ResetGameEvent extends AppEvent {}

class SelectOptionEvent extends AppEvent {
  int e;

  SelectOptionEvent(this.e);
}

class CellClickEvent extends AppEvent {
  int i, j;

  CellClickEvent(this.i, this.j);
}

class RandomizeEvent extends AppEvent {}

class TogglePlayEvent extends AppEvent {}

class GameBloc extends Bloc<AppEvent, AppState> {
  int rows = 10, cols = 10, bombs = 0;
  List<List<String>> grid = [];
  List<List<Color>> clr = [];
  List<List<bool>> vis = [];
  List<List<List<int>>> map = [];
  List<List<int>> dirs = [
    [0, 1],
    [0, -1],
    [1, 0],
    [-1, 0],
    [1, 1],
    [1, -1],
    [-1, 1],
    [-1, -1],
  ];
  List<int> startLoc = [], endLoc = [];
  bool play = false, start = false, end = false, block = false;
  final q = Queue<List<int>>();
  GameBloc() : super(GameLoadingState()) {
    on<LoadGameEvent>(
      (event, emit) {
        q.clear();
        map.clear();
        emit(GameLoadingState());
        grid = List.generate(rows, (_) => List.generate(cols, (x) => ' '));
        vis = List.generate(rows, (_) => List.generate(cols, (x) => false));

        clr = List.generate(
            rows, (_) => List.generate(cols, (x) => Colors.white));

        map = List.generate(rows, (_) => List.generate(cols, (x) => []));

        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            map[i][j] = [i, j];
          }
        }

        startLoc = [0, 0];
        endLoc = [rows - 1, cols - 1];
        grid[0][0] = 'O';
        clr[0][0] = const Color.fromARGB(255, 158, 235, 160);
        clr[rows - 1][cols - 1] = Colors.red;
        grid[rows - 1][cols - 1] = 'X';
        emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        emit(GameLoadingState());
        switch (event.e) {
          case 0:
            start = true;
            end = false;
            block = false;
            break;
          case 1:
            start = false;
            end = true;
            block = false;
            break;
          case 2:
            start = false;
            end = false;
            block = true;
            break;
        }

        emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
      },
    );

    on<CellClickEvent>(
      (event, emit) {
        int i = event.i, j = event.j;

        emit(GameLoadingState());
        if (start && grid[i][j] == ' ') {
          grid[startLoc[0]][startLoc[1]] = ' ';
          clr[startLoc[0]][startLoc[1]] = Colors.white;
          startLoc = [i, j];
          grid[startLoc[0]][startLoc[1]] = 'O';
          clr[startLoc[0]][startLoc[1]] =
              const Color.fromARGB(255, 158, 235, 160);
        } else if (end && grid[i][j] == ' ') {
          grid[endLoc[0]][endLoc[1]] = ' ';
          clr[endLoc[0]][endLoc[1]] = Colors.white;
          endLoc = [i, j];
          grid[endLoc[0]][endLoc[1]] = 'X';
          clr[endLoc[0]][endLoc[1]] = Colors.red;
        } else if (block) {
          if (grid[i][j] == '#') {
            grid[i][j] = ' ';
            clr[i][j] = Colors.white;
          } else if (grid[i][j] == ' ') {
            grid[i][j] = '#';
            clr[i][j] = Color.fromARGB(255, 222, 212, 120);
          }
        }
        emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
      },
    );

    on<RandomizeEvent>(
      (event, emit) {
        emit(GameLoadingState());
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            if (grid[i][j] == ' ' || grid[i][j] == '#') {
              grid[i][j] = (['#', ' ', ' ']..shuffle())[0];
              if (grid[i][j] == '#') {
                clr[i][j] = Color.fromARGB(255, 222, 212, 120);
              } else {
                clr[i][j] = Colors.white;
              }
            }
          }
        }
        emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
      },
    );

    on<TogglePlayEvent>(
      (event, emit) async {
        if (play) {
          emit(GameLoadingState());
          play = false;
          add(ResetGameEvent());
          return;
        } else {
          emit(GameLoadingState());
          play = true;
          emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
          // q.clear();
          q.addLast(startLoc);
          vis[startLoc[0]][startLoc[1]] = true;
          while (q.isNotEmpty && play) {
            int x = q.first[0], y = q.first[1];
            q.removeFirst();
            await Future.delayed(Duration(milliseconds: 300));
            if (!listEquals([x, y], startLoc)) clr[x][y] = Colors.white;

            if (listEquals([x, y], endLoc)) {
              // play = false;
              q.clear();
              // print('yes');
              break;
            }

            for (var dir in dirs) {
              int nx = x + dir[0], ny = y + dir[1];

              if (play &&
                  nx >= 0 &&
                  nx < rows &&
                  ny >= 0 &&
                  ny < cols &&
                  !vis[nx][ny] &&
                  (grid[nx][ny] == ' ' || grid[nx][ny] == 'X')) {
                emit(GameLoadingState());
                q.addLast([nx, ny]);
                vis[nx][ny] = true;
                map[nx][ny] = [x, y];
                // print('$nx, $ny: ${map[[nx, ny]]}');
                clr[nx][ny] = Colors.blue;
                emit(GameLoadedState(
                    play, start, end, block, grid, clr, rows, cols));
              }
            }
          }
          emit(GameLoadingState());
          for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
              if (grid[i][j] == ' ') clr[i][j] = Colors.white;
            }
          }

          int x = endLoc[0], y = endLoc[1];
          while (!listEquals(map[x][y], [x, y])) {
            emit(GameLoadingState());
            int nx = map[x][y][0], ny = map[x][y][1];
            clr[x][y] = Colors.green;
            x = nx;
            y = ny;
            emit(GameLoadedState(
                play, start, end, block, grid, clr, rows, cols));
          }
          emit(GameLoadedState(play, start, end, block, grid, clr, rows, cols));
        }
      },
    );

    on<ResetGameEvent>(
      (event, emit) {
        play = false;
        add(LoadGameEvent());
      },
    );
  }
}

// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:bfs_visualizer/bloc/appbloc.dart';
import 'package:bfs_visualizer/bloc/gamebloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => GameBloc()..add(LoadGameEvent()),
        child: BlocBuilder<GameBloc, AppState>(
          builder: (context, state) {
            if (state is GameLoadingState) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is GameLoadedState) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              'BFS visualizer',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: state.start
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  onPressed: state.play
                                      ? null
                                      : () {
                                          BlocProvider.of<GameBloc>(context)
                                              .add(SelectOptionEvent(0));
                                        },
                                  child: Text(
                                    'Start',
                                    style: TextStyle(
                                        color: state.start
                                            ? Colors.white
                                            : Colors.blue),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: state.end
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  onPressed: state.play
                                      ? null
                                      : () {
                                          BlocProvider.of<GameBloc>(context)
                                              .add(SelectOptionEvent(1));
                                        },
                                  child: Text(
                                    'End',
                                    style: TextStyle(
                                        color: state.end
                                            ? Colors.white
                                            : Colors.blue),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: state.block
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  onPressed: state.play
                                      ? null
                                      : () {
                                          BlocProvider.of<GameBloc>(context)
                                              .add(SelectOptionEvent(2));
                                        },
                                  child: Text(
                                    'Block',
                                    style: TextStyle(
                                        color: state.block
                                            ? Colors.white
                                            : Colors.blue),
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: state.play
                                      ? null
                                      : (() =>
                                          BlocProvider.of<GameBloc>(context)
                                              .add(RandomizeEvent())),
                                  child: Text('Randomize')),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: (() =>
                                      BlocProvider.of<GameBloc>(context)
                                          .add(TogglePlayEvent())),
                                  child:
                                      state.play ? Text('Stop') : Text('Play')),
                            ],
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Container(
                        // color: Colors.green,
                        child: ListView.builder(
                            // shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.rows,
                            itemBuilder: ((context, index) {
                              return Center(
                                  child: GridRow(context, state, index));
                            })),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        // color: Colors.black,
                        child: state.play
                            ? Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        BlocProvider.of<GameBloc>(context)
                                            .add(ResetGameEvent());
                                      },
                                      child: Text('Reset')),
                                  InkWell(
                                    child: Text(
                                        'https://github.com/dhairyajoshi/BFS-Visualizer'),
                                    onTap: () async {
                                      await launchUrl(Uri.parse(
                                          'https://github.com/dhairyajoshi/BFS-Visualizer'));
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox.shrink(),
                                  InkWell(
                                    child: Text(
                                        'https://github.com/dhairyajoshi/BFS-Visualizer'),
                                    onTap: () async {
                                      await launchUrl(Uri.parse(
                                          'https://github.com/dhairyajoshi/BFS-Visualizer'));
                                    },
                                  ),
                                  SizedBox(
                                    height: 15,
                                  )
                                ],
                              ),
                      ),
                    )
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class GridRow extends StatelessWidget {
  GridRow(this.ctx, this.state, this.rowno, {super.key});
  int rowno;
  GameLoadedState state;
  BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height / 15;
    double w = MediaQuery.of(context).size.width / 12;
    return Container(
      // width: w,
      height: h,
      decoration: BoxDecoration(
          // border: Border.all(color: Colors.black, width: 1),

          ),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: state.cols,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: ((context, index) {
            return GestureDetector(
              onTap: () {
                if (!state.play) {
                  BlocProvider.of<GameBloc>(ctx)
                      .add(CellClickEvent(rowno, index));
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width < 493 ? w : h,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: state.clr[rowno][index],
                ),
                // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Center(
                    child: Text(
                  state.grid[rowno][index],
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
              ),
            );
          })),
    );
  }
}

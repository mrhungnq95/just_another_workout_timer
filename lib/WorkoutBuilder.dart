import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/NumberStepper.dart';
import 'package:just_another_workout_timer/StorageHelper.dart';
import 'package:just_another_workout_timer/Utils.dart';
import 'package:just_another_workout_timer/Workout.dart';

class BuilderPage extends StatefulWidget {
  final Workout workout;
  final bool newWorkout;

  BuilderPage({Key key, @required this.workout, @required this.newWorkout})
      : super(key: key);

  @override
  _BuilderPageState createState() => _BuilderPageState(workout, newWorkout);
}

/// page allowing a user to create a workout
class _BuilderPageState extends State<BuilderPage> {
  Workout _workout;
  String _oldTitle;
  bool _newWorkout;

  _BuilderPageState(Workout workout, bool newWorkout) {
    _workout = workout;
    _oldTitle = _workout.title;
    _newWorkout = newWorkout;
  }

  void _addSet() {
    setState(() {
      _workout.sets.add(Set.empty());
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _workout.sets.removeAt(index);
    });
  }

  void saveWorkout() {
    if (_workout.title == '') {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Please enter a name for the workout!'),
            );
          });
      return;
    }
    setState(() {
      _workout.cleanUp();
    });
    if (!_newWorkout) StorageHelper.deleteWorkout(_oldTitle);
    StorageHelper.writeWorkout(_workout);
    _oldTitle = _workout.title;
  }

  void _addExercise(int setIndex, bool isRest) {
    setState(() {
      _workout.sets[setIndex].exercises
          .add(Exercise.withName(isRest ? 'Rest' : 'Exercise'));
    });
  }

  void _deleteExercise(int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises.removeAt(exIndex);
    });
  }

  Widget _buildSetList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < _workout.sets.length) {
          return _buildSetItem(_workout.sets[index], index);
        } else
          return null;
      },
    );
  }

  Widget _buildSetItem(Set set, int index) {
    return Card(
        key: Key(set.toRawJson()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.delete),
                    tooltip: 'Delete set',
                    onPressed: () {
                      _deleteSet(index);
                    }),
                Expanded(
                  child: ListTile(
                    title: Text(
                      'Set ${_workout.sets.indexOf(set) + 1}',
                    ),
                    subtitle: Text('${Utils.formatSeconds(set.duration)}'),
                  ),
                ),
                Text('Repetitions:'),
                NumberStepper(
                    lowerLimit: 0,
                    upperLimit: 99,
                    stepValue: 1,
                    formatNumber: false,
                    value: set.repetitions,
                    valueChanged: (int repetitions) {
                      setState(() {
                        set.repetitions = repetitions;
                      });
                    })
              ],
            ),
            _buildExerciseList(set, index),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.fitness_center),
                      tooltip: 'Add exercise',
                      onPressed: () {
                        _addExercise(index, false);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.pause_circle_filled),
                      tooltip: 'Add rest',
                      onPressed: () {
                        _addExercise(index, true);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward),
                      tooltip: 'Move set up',
                      onPressed: index - 1 >= 0
                          ? () {
                              setState(() {
                                _workout.moveSet(index, true);
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward),
                      tooltip: 'Move set down',
                      onPressed: index + 1 < _workout.sets.length
                          ? () {
                              setState(() {
                                _workout.moveSet(index, false);
                              });
                            }
                          : null,
                    )
                  ],
                ),
              ],
            )
          ],
        ));
  }

  Widget _buildExerciseList(Set set, int setIndex) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          if (index < _workout.sets[setIndex].exercises.length) {
            return _buildExerciseItem(
                setIndex, index, set.exercises[index].name);
          } else
            return null;
        });
  }

  Widget _buildExerciseItem(int setIndex, int exIndex, String name) {
    return Card(
      color: Theme.of(context).backgroundColor,
      child: Row(
        key: Key(_workout.sets[setIndex].exercises[exIndex].toRawJson()),
        children: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete exercise',
            onPressed: () {
              _deleteExercise(setIndex, exIndex);
            },
          ),
          Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: name,
                maxLength: 30,
                maxLengthEnforced: true,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Exercise',
                ),
                onChanged: (text) {
                  _workout.sets[setIndex].exercises[exIndex].name = text;
                },
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NumberStepper(
                lowerLimit: 0,
                upperLimit: 995,
                stepValue: 5,
                formatNumber: true,
                value: _workout.sets[setIndex].exercises[exIndex].duration,
                valueChanged: (int duration) {
                  setState(() {
                    _workout.sets[setIndex].exercises[exIndex].duration =
                        duration;
                  });
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    padding: EdgeInsets.zero,
                    tooltip: 'Move exercise up',
                    onPressed: exIndex - 1 >= 0
                        ? () {
                            setState(() {
                              _workout.sets[setIndex]
                                  .moveExercise(exIndex, true);
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    padding: EdgeInsets.zero,
                    tooltip: 'Move exercise down',
                    onPressed:
                        exIndex + 1 < _workout.sets[setIndex].exercises.length
                            ? () {
                                setState(() {
                                  _workout.sets[setIndex]
                                      .moveExercise(exIndex, false);
                                });
                              }
                            : null,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Are you sure you want to exit?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes, exit'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });

        return value == true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextFormField(
              initialValue: _workout.title,
              maxLength: 30,
              maxLengthEnforced: true,
              maxLines: 1,
              onChanged: (String name) {
                _workout.title = name;
              },
              decoration: InputDecoration(
                labelText: 'Name',
              )),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save workout',
              onPressed: saveWorkout,
            )
          ],
        ),
        body: Center(
          child: _buildSetList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addSet,
          tooltip: 'Add Set',
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

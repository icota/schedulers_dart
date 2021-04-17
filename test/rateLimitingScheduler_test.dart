// SPDX-FileCopyrightText: (c) 2021 Artёm IG <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:schedulers/schedulers.dart';
import 'package:test/test.dart';

void main() {
  test('RateLimitingScheduler Limiting', () async {
    const F = 2;
    var scheduler = RateScheduler(3, const Duration(milliseconds: 100 * F));

    int a = 0;

    void taskA() {
      a++;
    }

    for (var i = 0; i < 10; ++i) {
      scheduler.run(taskA);
    }

    expect(a, 0);

    // we run three tasks immediately. Half interval passed, but they are all completed
    await Future.delayed(Duration(milliseconds: 50 * F));
    expect(a, 3);

    await Future.delayed(Duration(milliseconds: 100 * F));
    expect(a, 6);

    await Future.delayed(Duration(milliseconds: 100 * F));
    expect(a, 9);

    await Future.delayed(Duration(milliseconds: 100 * F));
    expect(a, 10);
  });

  test('RateLimitingScheduler Different Tasks', () async {
    const F = 1;
    var scheduler = RateScheduler(5, Duration(milliseconds: 100 * F));

    int a = 0;
    int b = 0;
    int c = 0;

    void taskA() {
      a++;
    }

    void taskB() {
      b++;
    }

    void taskC() {
      c++;
    }

    var tasks = [];
    for (int i = 0; i < 4; ++i) {
      tasks.add(taskA);
    }
    for (int i = 0; i < 3; ++i) {
      tasks.add(taskB);
    }
    for (int i = 0; i < 6; ++i) {
      tasks.add(taskC);
    }

    tasks.shuffle();

    for (var t in tasks) {
      scheduler.run(t);
    }

    await Future.delayed(Duration(milliseconds: 500 * F));

    expect(a, 4);
    expect(b, 3);
    expect(c, 6);
  });

  test('RateLimitingScheduler Future', () async {
    var scheduler = RateScheduler(5, Duration(milliseconds: 100));

    int a = 0;
    int funcOk() {
      return ++a;
    }

    int funcOops() {
      throw Exception('Oops');
    }

    var task1 = scheduler.run(funcOk);
    var taskZ = scheduler.run(funcOops);
    var task2 = scheduler.run(funcOk);

    expect(() async => await taskZ.result, throwsException);
    expect(await task2.result, 2);
    expect(await task1.result, 1);
  });
}

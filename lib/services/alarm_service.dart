import 'package:audioplayers/audioplayers.dart';

// Top-level function for alarm callback (required by android_alarm_manager_plus)
void alarmCallback() async {
  final player = AudioPlayer();
  await player.setReleaseMode(ReleaseMode.loop); // Enable looping
  await player.play(
    AssetSource('sounds/alarm.mp3'),
    volume: 1.0,
    mode: PlayerMode.lowLatency,
  );
}

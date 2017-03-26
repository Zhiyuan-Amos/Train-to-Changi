///
/// Class that plays the audio.
///

import AVFoundation
class AudioPlayer {
    static let sharedInstance = AudioPlayer()
    private var backgroundMusicPlayer: AVAudioPlayer

    private init() {
        backgroundMusicPlayer = AVAudioPlayer()
    }

    func playBackgroundMusic() {
        let url = Bundle.main.url(forResource: Constants.Audio.bgMusic,
                                  withExtension: ".mp3")!
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
            backgroundMusicPlayer.volume = 0.3
        } catch {
            return
        }
    }
}

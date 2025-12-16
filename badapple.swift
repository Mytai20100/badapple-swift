import Foundation

let ASCII_CHARS = " .:-=+*#%@"
let WIDTH = 80
let HEIGHT = 40

func downloadVideo(url: String) {
    print("Downloading video...")
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["yt-dlp", "-f", "worst", "-o", "video.mp4", url]
    task.launch()
    task.waitUntilExit()
}

func rgbToAscii(r: UInt8, g: UInt8, b: UInt8) -> Character {
    let brightness = (Int(r) + Int(g) + Int(b)) / 3
    let index = brightness * (ASCII_CHARS.count - 1) / 255
    return ASCII_CHARS[ASCII_CHARS.index(ASCII_CHARS.startIndex, offsetBy: index)]
}

func extractAndDisplayFrame(time: Double) {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", "ffmpeg -ss \(time) -i video.mp4 -vframes 1 -vf scale=\(WIDTH):\(HEIGHT) -f rawvideo -pix_fmt rgb24 - 2>/dev/null"]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    if !data.isEmpty {
        print("\u{001B}[2J\u{001B}[H")
        
        for y in 0..<HEIGHT {
            for x in 0..<WIDTH {
                let idx = (y * WIDTH + x) * 3
                if idx + 2 < data.count {
                    let r = data[idx]
                    let g = data[idx + 1]
                    let b = data[idx + 2]
                    print(rgbToAscii(r: r, g: g, b: b), terminator: "")
                }
            }
            print()
        }
    }
}

let url = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "https://youtu.be/FtutLA63Cp8"
downloadVideo(url: url)

let fps = 10.0
let duration = 30.0
var time = 0.0

while time < duration {
    extractAndDisplayFrame(time: time)
    Thread.sleep(forTimeInterval: 1.0 / fps)
    time += 1.0 / fps
}

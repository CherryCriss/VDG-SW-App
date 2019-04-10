//
//  LyricsGenerator.swift
//  Expandable-TableViewCell-StackView
//
//  Created by Home on 09/07/16.
//  Copyright © 2016 Akash Malhotra. All rights reserved.
//

import Foundation

class LyricsGenerator {
    
    static func getLyrics() -> [Lyrics] {
        var allLyrics = [Lyrics]()
        
        allLyrics.append(Lyrics(artist: "", song: "What is scratch and win?", lyricsSample: "Scratch and Win is a mobile app designed for the VeriDoc Global community to help spread awareness. Using fun scratch cards, you’ll get to learn about some of the different solutions that VeriDoc Global has to offer. There is no cost to play and some seriously cool merchandise to be won. Have you started scratching yet?\n"))
        
        allLyrics.append(Lyrics(artist: "", song: "What is VeriDoc Global?", lyricsSample: "VeriDoc Global is a patented blockchain solution that eliminates document fraud and counterfeits. Using a mobile device, anyone can simply scan a VeriDoc Global secured QR code and verify within seconds whether something is real or fake. To learn more please visit our website: www.veridocglobal.com\n"))
        
        
//        allLyrics.append(Lyrics(artist: "", song: "When will I be able to redeem my VDG tokens?", lyricsSample: "VeriDoc Global will cover the cost of gas (blockchain transaction fees) associated with transferring your VDG tokens to your personal wallet. In order to reduce gas fees and to be able to give away more VDG tokens, we’ve set the minimum redeemable amount to 10,000 VDG tokens. Once you’ve hit the 10,000 VDG tokens mark or more, you’ll be able to redeem the tokens by pressing the Gift icon in the My Rewards screen.\n"))
//
//        allLyrics.append(Lyrics(artist: "", song: "Do I need to have a crypto wallet to redeem my winnings?", lyricsSample: "Yes. Once you hit the 10,000 VeriDoc Global mark or more, you’ll need to provide us with a wallet address for us to transfer your VDG tokens. Your wallet address is also referred to as a public key. We will never ask for your private key.\n"))
//
//        allLyrics.append(Lyrics(artist: "", song: "The app says that I am out of scratches, but I can see some scratches at the bottom of my screen. Why can’t I scratch anymore?", lyricsSample: "There are two different types of scratch counters:\n  •    Scratches available per day, which is three (3). The maximum number of times a user can play Scratch and Win is three times per day, which refreshes every 24 hours.\n  •    Scratches Remaining, which is the total number of scratches remaining in the game.\n"))
//
//        allLyrics.append(Lyrics(artist: "", song: "If I don’t use the app for next two days and I get three new scratches every day, does that mean that when I come back on the third day, I can play nine times?", lyricsSample: "No. The daily limit refreshes every 24 hours and unused scratches will not roll over to the next day.\n"))
        
         allLyrics.append(Lyrics(artist: "", song: "The app says that I am out of scratches, but I can see some scratches at the bottom of my screen. Why can’t I scratch anymore?", lyricsSample: "There are two different types of scratch counters:\n\n1.  Scratches available per day, which is three (3). The maximum number of times a user can play Scratch and Win is three times per day, which refreshes every 24 hours.\n\n2. Scratches Remaining, which is the total number of scratches remaining in the game.\n"))
        
        allLyrics.append(Lyrics(artist: "", song: "If I don’t use the app for next two days and I get three new scratches every day, does that mean that when I come back on the third day, I can play nine times?", lyricsSample: "No. The daily limit refreshes every 24 hours and unused scratches will not roll over to the next day.\n"))
        
        
        
         allLyrics.append(Lyrics(artist: "", song: "Can I register multiple accounts to win more times?", lyricsSample: "No. Our terms clearly state that only one account is allowed per user. If a user is caught registering multiple accounts, they risk being disqualified.\n"))
        
        
         allLyrics.append(Lyrics(artist: "", song: "For more information Click Here", lyricsSample: ""))
        
        
        
      
        return allLyrics
    }
}

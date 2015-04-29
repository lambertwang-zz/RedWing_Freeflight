AudioSample singleGun;
AudioSample grenadeLaunch;
AudioSample beamGun;

AudioSample[] explosion;

AudioPlayer current;
int currentScreen;
ArrayList<AudioPlayer> musicMenu;
ArrayList<AudioPlayer> musicGame;

void setupAudio(){
    singleGun = minim.loadSample("sounds/single_gun.wav", 512);;
    beamGun = minim.loadSample("sounds/ray_gun.wav", 512);
    grenadeLaunch = minim.loadSample("sounds/grenade_launch.wav", 512);

    explosion = new AudioSample[3];
    explosion[0] = minim.loadSample("sounds/explosion1.wav", 512);
    explosion[1] = minim.loadSample("sounds/explosion2.wav", 512);
    explosion[2] = minim.loadSample("sounds/explosion3.wav", 512);

    musicMenu = new ArrayList();
    musicGame = new ArrayList();

    musicGame.add(minim.loadFile("sounds/Cave Story  Remastered Soundtrack - #35 Running Hell (Curly's Theme).wav"));
    musicMenu.add(minim.loadFile("sounds/Cave Story+ Remastered Soundtrack - #25 Moonsong.wav"));
    musicGame.add(minim.loadFile("sounds/Cave Story+ Remastered Soundtrack - #30 Last Cave (Perfect Run).wav"));
    musicMenu.add(minim.loadFile("sounds/Cave Story+ Remastered Soundtrack - #36 Torako's Theme.wav"));
    musicGame.add(minim.loadFile("sounds/Cave Story+ Remastered Soundtrack - #39 Mischievous Robot (Ending Credit Mix).wav"));
    musicGame.add(minim.loadFile("sounds/Cave Story+ Remastered Soundtrack - #40 Wind Fortress.wav"));

    current = null;
    currentScreen = -1;
}

void playMusic(){
    if(current == null){
        println("Test");
        nextSong();
    } else if(currentScreen != screen) {
        current.pause();
        nextSong();
    } else if (!current.isPlaying()) {
        nextSong();
    }
}

void nextSong(){
    int tempIndex;
    currentScreen = screen;
    switch(screen){
        case 0:
            tempIndex = floor(random(0, musicGame.size()-1));
            current = musicGame.get(tempIndex);
            musicGame.add(musicGame.remove(tempIndex));
            current.setGain(-9);
            current.play();
            break;
        case 1:
            tempIndex = floor(random(0, musicMenu.size()-1));
            current = musicMenu.get(tempIndex);
            musicMenu.add(musicMenu.remove(tempIndex));
            current.setGain(-9);
            current.play();
            break;
    }
}


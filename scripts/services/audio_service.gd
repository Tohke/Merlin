## Autoload (Singleton): centraliza a reprodução de som do jogo inteiro.
## Responsabilidade única: tocar/parar SFX e música. Nenhuma outra parte do
## jogo deve carregar AudioStream diretamente — chame estas funções.
##
## Você tem apenas 2 arquivos de som reais: clique e música de fundo (a
## mesma música toca do título ao fim do quiz, sem trocar de faixa).
extends Node

const SFX_CLICK_PATH: String = "res://audio/sfx_click.mp3"
const MUSIC_PATH: String = "res://audio/music.mp3"

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

var sfx_volume_db: float = 0.0
var music_volume_db: float = -8.0

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	_sfx_player.bus = "Master"
	add_child(_sfx_player)

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	add_child(_music_player)

func _play_sfx(path: String) -> void:
	if not ResourceLoader.exists(path):
		return # som ainda não presente — falha silenciosa, não quebra o jogo
	var stream := load(path)
	_sfx_player.stream = stream
	_sfx_player.volume_db = sfx_volume_db
	_sfx_player.play()

## Único som de efeito disponível: usado em todos os cliques de botão.
func play_click() -> void:
	_play_sfx(SFX_CLICK_PATH)

## Toca a música de fundo (mesma faixa do título ao fim do quiz).
## Não reinicia se já estiver tocando.
func play_background_music() -> void:
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	if _music_player.playing:
		return
	var stream = load(MUSIC_PATH)
	if stream is AudioStreamMP3:
		stream.loop = true
	_music_player.stream = stream
	_music_player.volume_db = music_volume_db
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

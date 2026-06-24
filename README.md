# Completar a Palavra — Versão Atualizada

## O que foi corrigido (bugs no que você já tinha)

1. **`audio_service.gd` estava incompleto/inconsistente** — faltavam funções
   chamadas pelo `quiz_screen.gd` antigo. Agora está simplificado para os
   2 sons reais que você tem: `sfx_click.mp3` (cliques) e `music.mp3`
   (música única, do título ao fim do quiz, sem trocar de faixa).
2. **`question.gd` tinha um bug de assinatura** — o `from_dict` não batia
   com o construtor (`category_icon` sobrando). Corrigido e padronizado
   sem ícone de categoria, consistente com o `category.gd`.
3. **Caminhos de áudio**: como você só tem `sfx_click.mp3` e `music.mp3`,
   removi as referências a `sfx_correct`/`sfx_wrong`/`sfx_victory`/
   `music_title`/`music_quiz` que existiam em versões antigas do código.

## O que mudou no visual (baseado no seu HTML de referência)

- Paleta escura azul/laranja (`#0f172a`, `#38bdf8`, `#f97316`) aplicada em
  `option_button_factory.gd` (cores e estilos centralizados ali).
- **Cartão de pergunta** com borda/glow que fica verde ao acertar e
  vermelho ao errar, com animação de entrada (fade + slide), como o
  `.card.enter` do CSS.
- **Badge de pontuação** (`⚡ X pts`) com efeito de "pop" ao acertar.
- **Barra de progresso** animada, mostrando "Questão X de N" e percentual.
- **Modal de explicação** mantido (conforme você pediu), com visual
  atualizado: borda colorida no topo, fade + scale ao abrir, fade ao
  fechar antes de avançar.
- **Confete e estrelas** mantidos, com paleta de cores atualizada.
- **Botão "🏠 Menu"** sempre visível no topo da tela de quiz, além do
  botão na tela final — volta para `TitleScreen` em qualquer momento.

## Regra de quantidade de perguntas (em `question_repository.gd`)

- **"Todas as Categorias"**: sorteia `min(10, total_geral_de_perguntas)`.
- **Categoria específica**: sorteia `min(5, total_da_categoria)`.
- A cada partida (inclusive ao clicar "Jogar de Novo"), a seleção e a
  ordem são sorteadas de novo — garante rejogabilidade.

Esses números são constantes no topo do arquivo
(`QUESTION_COUNT_ALL` e `QUESTION_COUNT_CATEGORY`), fácil de ajustar depois
se quiser mudar a quantidade.

## Como integrar no seu projeto Godot

1. Copie `scripts/`, `scenes/` e `data/questions.json` para a raiz do seu
   projeto, substituindo os arquivos antigos de mesmo nome.
2. **Apague** `game.gd` e `Game.tscn` antigos (não são mais usados).
3. Confirme no **Project Settings**:
   - **Autoload**: `AudioService` → `res://scripts/services/audio_service.gd`,
     `GameState` → `res://scripts/autoload/game_state.gd`
   - **Run > Main Scene**: `res://scenes/TitleScreen.tscn`
4. Confirme que `res://audio/sfx_click.mp3` e `res://audio/music.mp3`
   existem com esses nomes exatos (são os únicos sons referenciados agora).
   Se o seu arquivo de música tiver outro nome, ajuste a constante
   `MUSIC_PATH` em `scripts/services/audio_service.gd`.
5. Edite `data/questions.json` para colocar suas próprias perguntas —
   o formato é: cada categoria tem `id`, `name` e uma lista `questions`,
   cada pergunta com `question`, `options` (array), `correct_answer`
   (índice da opção correta) e `explanation`.

## Arquivos não usados nesta entrega

Os arquivos `.uid` ao lado de cada `.gd` são gerados automaticamente pelo
Godot — não precisa recriá-los manualmente, o editor regenera ao abrir
o projeto.

## Autoload (Singleton): guarda informação que precisa atravessar a troca
## de cena (qual categoria foi escolhida na tela de título).
## Responsabilidade única: estado compartilhado entre cenas.
extends Node

var selected_category_id: String = CategoryData.ALL_CATEGORIES_ID

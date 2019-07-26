import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jutpatti/models/card.dart';
import 'package:jutpatti/resources/notifiers/game_state.dart';
import 'package:jutpatti/widgets/playing_card.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]); */
    return ChangeNotifierProvider(
      builder: (context) => GameState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards'),
      ),
      body: SingleChildScrollView(
        child: Consumer<GameState>(
          builder: (context, gameState, _) {
            return Column(children: [
              ...gameState.players.map((player) {
                int index = gameState.players.indexOf(player);
                return DragTarget<Map<String, dynamic>>(
                  onAccept: (data) {
                    print(data);
                    gameState.accept(data);
                  },
                  onWillAccept: (_) {
                    return gameState.turn == index &&
                        player.cards.length == gameState.numberOfCardsInHand;
                  },
                  builder: (_, pcard, ___) => Row(
                    children: player.cards
                        .map((card) => Draggable(
                            data: card,
                            childWhenDragging: Container(),
                            feedback: TransformedCard(
                              playingCard: card,
                            ),
                            child: TransformedCard(
                              playingCard: card,
                            )))
                        .toList(),
                  ),
                );
              }),
              const SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Text("Deck"),
                  if (gameState.deck.length > 0)
                    Draggable(
                      data: {
                        "from": "deck",
                        "card": gameState.deck[0],
                      },
                      child: TransformedCard(
                        playingCard: gameState.deck[0],
                      ),
                      feedback: Container(
                        child: TransformedCard(
                          playingCard: gameState.deck[0],
                        ),
                      ),
                      childWhenDragging: TransformedCard(
                        playingCard: gameState.deck[1],
                      ),
                    ),
                  Text("Joker"),
                  if (gameState.joker != null)
                    TransformedCard(
                      playingCard: gameState.joker,
                    ),
                  Text("thrown"),
                  DragTarget<PlayingCard>(
                    builder: (context, _, __) {
                      return gameState.throwDeck.length > 0
                          ? TransformedCard(
                              playingCard: gameState.throwDeck[0],
                            )
                          : Container(
                              color: Colors.green,
                              height: 60,
                              width: 40,
                            );
                    },
                    onWillAccept: (_) {
                      return gameState.playType == PlayType.THROW_FROM_HAND;
                    },
                    onAccept: (pcard) {
                      gameState.throwCard(pcard);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text("turn: ${gameState.turn}"),
              RaisedButton(
                onPressed: () {
                  gameState.beginGame();
                },
                child: Text("Begin game"),
              ),
              if (gameState.winner != null)
                Text("Winner: ${gameState.winner.name}"),
            ]);
          },
        ),
      ),
    );
  }
}

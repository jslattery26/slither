import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:url_launcher/url_launcher.dart';

import 'game_colors.dart';
import 'menu_card.dart';
import 'slither/slither.dart';

class Menu extends StatelessWidget {
  const Menu(this.game, {super.key});

  final Slither game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            Column(
              children: [
                MenuCard(
                  children: [
                    Text(
                      'PadRacing',
                      style: textTheme.headline1,
                    ),
                    Text(
                      'First to 3 laps win',
                      style: textTheme.bodyText1,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('1 Player'),
                      onPressed: () {},
                    ),
                    Text(
                      'Arrow keys',
                      style: textTheme.bodyText2,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('2 Players'),
                      onPressed: () {},
                    ),
                    Text(
                      'ASDW',
                      style: textTheme.bodyText2,
                    ),
                  ],
                ),
                MenuCard(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Made by ',
                            style: textTheme.bodyText2,
                          ),
                          TextSpan(
                            text: 'Lukas Klingsbo (spydon)',
                            style: textTheme.bodyText2?.copyWith(
                              color: GameColors.green.color,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                final _url =
                                    Uri.parse('https://github.com/spydon');
                                launchUrl(_url);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

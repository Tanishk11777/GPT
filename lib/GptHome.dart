import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:gpt/Colours.dart';
import 'package:gpt/feature_box.dart';
import 'package:gpt/openai_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GptHome extends StatefulWidget {
  const GptHome({super.key});

  @override
  State<GptHome> createState() => _GptHomeState();
}

class _GptHomeState extends State<GptHome> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords='';
  final OpenAIService openAIService=OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: BounceInDown(child: const Text("Voice Assistant")),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Container(
                    height: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage(
                        "assets/images/assi.png"
                      ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            //chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 25).copyWith(top: 10,),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      generatedContent == null ? 'Hey there what task can I do for you?':generatedContent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent==null ? 25:18,
                        fontFamily: 'Cera Pro',
                    ),),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(
                    top: 10,
                    left: 22,
                  ),
                  child: const Text('Here are a few features',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            ),
            //List
            Visibility(
              visible: generatedContent==null && generatedImageUrl==null,
              child: Column(
                  children: [
                      SlideInLeft(
                        delay: Duration(microseconds: start),
                        child: const FeatureBox(
                          color: Pallete.firstSuggestionBoxColor,
                          headerText: 'ChatGPT',
                          descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                        ),
                      ),
                      SlideInLeft(
                        delay: Duration(microseconds: start+delay),
                        child: FeatureBox(
                          color: Pallete.secondSuggestionBoxColor,
                          headerText: 'Dall-E',
                          descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                        ),
                      ),
                     SlideInLeft(
                       delay: Duration(microseconds: start+2*delay),
                       child: FeatureBox(
                          color: Pallete.thirdSuggestionBoxColor,
                          headerText: 'Smart Voice Assistant',
                          descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                        ),
                     ),
                  ],
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(microseconds: start+3*delay),
        child: FloatingActionButton(
          onPressed: () async{
            if(await speechToText.hasPermission && !speechToText.isListening){
              await startListening();
            }else if(speechToText.isListening){
              print(lastWords);
              final speech = await openAIService.isArtPromptAPI(lastWords);
              print(speech);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            }else{
              initSpeechToText();
            }
          },
          backgroundColor: Pallete.firstSuggestionBoxColor,
          child: Icon(
            speechToText.isListening ? Icons.stop: Icons.mic_none_outlined,
              color: Pallete.blackColor,
          ),
        ),
      ),
    );
  }
}
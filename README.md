## **MovieQuiz**

Movie Quiz is an application featuring quizzes about films from the IMDb Top 250 and most popular movies lists.

## **Links**

[Figma](https://www.figma.com/file/l0IMG3Eys35fUrbvArtwsR/YP-Quiz?node-id=34%3A243)

[API IMDb](https://imdb-api.com/api#Top250Movies-header)

[Fonts](https://code.s3.yandex.net/Mobile/iOS/Fonts/MovieQuizFonts.zip)

## **Application Description**

- A single-page application with quizzes about films from the IMDb Top 250 rating and most popular films. Users answer consecutive questions about film ratings. At the end of each game round, statistics about the number of correct answers and the user's best results are displayed. The goal is to answer all 10 questions in a round correctly.

## **Functional Requirements**

- A splash screen appears when launching the application
- After launch, a question screen appears with question text, an image, and two answer options, "Yes" and "No", with only one being correct
- Quiz questions are formulated regarding the IMDb rating of films on a 10-point scale, for example: "Is this movie rated higher than 6?"
- Users can select an answer option and receive feedback on whether it's correct, with the photo frame changing color accordingly
- After choosing an answer, the next question automatically appears after 1 second
- Upon completion of a 10-question round, an alert appears with user statistics and an option to play again
- Statistics include: current round result (number of correct answers out of 10 questions), number of quizzes played, record (best round result for the session, including date and time), and statistics of played quizzes as a percentage (average accuracy)
- Users can start a new round by clicking the "Play again" button in the alert
- If data cannot be loaded, users see an alert with a message indicating something went wrong, along with a button to retry the network request

## **Technical Requirements**

- The application must support iPhone devices with iOS 15, with portrait mode only
- Interface elements must adapt to iPhone screen resolutions, starting from iPhone X — layouts for SE and iPad are not required
- Screens must match the design layout — using correct fonts of the required sizes, with all text in the proper position, and the placement of all elements, button sizes, and margins exactly as specified in the layout

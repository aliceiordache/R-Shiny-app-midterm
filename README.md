# R-Shiny-app-midterm

The following app displays a wordcloud of the most used words by characters from the Game of Thrones tv series. The app is the last step of a previous personal project, evaluating through basic algorithms and neural networks the probability that a given character pronounced a given sentence.
As you can see from the app, on the up right you can choose the character from the show and by clicking on "generate" the corresponding wordcloud will generate.

For what concerns the technicalities of the app:
Data Acquisition: data imported locally from a csv
Data Visualization: using Plotly a plot returning the characters who say most sentences
Data Analysis: mostly text cleaning.
  - 3 interactive choices in the WordCloud, namely: select the character to be displayed; choose how many words to be dsiplayed in the wordcloud per total; choose to display words depending on their frequency.
 
There is also a user-defined function: the one creating the TermDocument Matrix.
No parallel computing techniques, given that the app is very fast, therefore not necessary in this exercise. However, we can highlight that there is a reactive component: the one generating the TermDocument Matrix. This speeds up the code (code optimizionation), even though it does not concern parallel computing.

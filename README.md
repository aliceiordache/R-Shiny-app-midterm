# R-Shiny-app-midterm

Preso il dataset di got e fatto la shiny.
Data acquisition: c'è, prendiamo i dati da un local csv.
Data visualization: c'è, riportato un plot dei characters che dicono più frasi (usando plotly)
Data analysis: c'è, molto basic, ma c'è la pulizia del testo. Interactive choices ce ne sono 3 nel wordcloud: puoi scegliere il personaggio di cui mostrare il wc, puoi scegliere quante parole mostrare nel wc in totale e puoi scegliere di filtrare le parole in base alla loro frequenza. Una user-defined function c'è, ed è quella che ti crea la Term-Document Matrix
L'unica cosa che forse manca è la code optimization perchè è talmente già veloce di suo che non c'è bisogno di parallel computing o cose della nasa. Un reactive component c'è ed è quello che ti genera la TermDocument Matrix. Questo vuol dire che se tu prima scegli Arya, lui ti calcola la matrice e te la salva in cache. Poi scegli Cersei, la calcola per lei. Poi scegli di nuovo Arya, la matrice è già stata calcolata e usa quella e quindi velocizza (non è parallel computing ma è code optimization comunque...)

from keras.preprocessing.sequence import pad_sequences
from keras.preprocessing.text import Tokenizer
import keras.utils as ku
from keras.models import load_model

import pandas as pd
import numpy as np

def prep_data(fname, mname):
    
    model = load_model(mname)
    
    df = pd.read_csv(fname)
    
    df1 = df.copy()
    
    df1['text'] = df['text'].str[2:-1] #each string starts with b' and ends with ', so this removes those characters
    df1['text'] = df1['text'].str.lower()
    
    words_list = df1['text'].values
    
    for i in ['https://', '@', '\\']:
        words_list = [word for word in words_list if not i in word]
    
    tokenizer = Tokenizer()
    
    tokenizer.fit_on_texts(words_list)
    total_words = len(tokenizer.word_index) + 1
    
    input_seq = []
    for line in words_list:
        token_list = tokenizer.texts_to_sequences([line])[0]
        for i in range(1, len(token_list)):
            n_gram_sequence = token_list[:i+1]
            input_seq.append(n_gram_sequence)

    max_seq_len = max([len(x) for x in input_seq])
    input_seq = np.array(pad_sequences(input_seq, maxlen = max_seq_len, padding = 'pre'))
    
    predictors, label = input_seq[:,:-1], input_seq[:,-1]
    label = ku.to_categorical(label, num_classes = total_words)
    return [model, max_seq_len, tokenizer]

def generate_text(seed_text, next_words, model, max_seq_len, tokenizer):
    for _ in range(next_words):
        token_list = tokenizer.texts_to_sequences([seed_text])[0]
        token_list = pad_sequences([token_list], maxlen = max_seq_len - 1, padding = 'pre')
        predicted = model.predict_classes(token_list, verbose = 0)
        
        output_word = ""
        for word,index in tokenizer.word_index.items():
            if index == predicted:
                output_word = word
                break
        seed_text += " "+output_word
    return(seed_text.title() + '\n')
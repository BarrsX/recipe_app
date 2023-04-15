/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable max-len */
require('dotenv').config();
import * as functions from 'firebase-functions';
import fetch from 'node-fetch';

const {SPOONACULAR_API_KEY} = process.env;

export const getSuggestionList = functions.https.onCall(async (data, context) => {
  const query = data.query as string;
  console.log(query);
  let url = `https://api.spoonacular.com/recipes/autocomplete?number=5&query=${query}&apiKey=${SPOONACULAR_API_KEY}`;

  url = url.replace(/[';]/g, '');

  try {
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });

    if (response.ok) {
      const data = await response.json();
      return data;
    } else {
      console.log(`Error: ${response.status} ${response.statusText}`);
    }
  } catch (e) {
    console.error(`Error: ${e}`);
  }
});

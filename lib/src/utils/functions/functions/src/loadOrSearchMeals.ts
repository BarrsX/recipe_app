/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable max-len */
require('dotenv').config();
import * as functions from 'firebase-functions';
import fetch from 'node-fetch';

const {SPOONACULAR_API_KEY} = process.env;

export const loadOrSearchMeals = functions.https.onCall(async (data, context) => {
  const query: string = data.query || '' as string;
  let url =
  query === '' ?
    `https://api.spoonacular.com/recipes/random?number=15&addRecipeInformation=true&apiKey=${SPOONACULAR_API_KEY}` :
    `https://api.spoonacular.com/recipes/complexSearch?query=${query}&addRecipeInformation=true&apiKey=${SPOONACULAR_API_KEY}`;

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
      throw new functions.https.HttpsError('internal', response.statusText);
    }
  } catch (e: any) {
    console.error(`Error: ${e}`);
    throw new functions.https.HttpsError('internal', e.message);
  }
});

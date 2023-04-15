/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable max-len */
require('dotenv').config();

import * as functions from 'firebase-functions';
import fetch from 'node-fetch';

const {SPOONACULAR_API_KEY} = process.env;


// Cloud function that retrieves recipe by ID from Spoonacular API
export const getRecipeById = functions.https.onCall(async (data, context) => {
  const mealId: string = data.mealId as string;

  let url = `https://api.spoonacular.com/recipes/${mealId}/information?apiKey=${SPOONACULAR_API_KEY}`;

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

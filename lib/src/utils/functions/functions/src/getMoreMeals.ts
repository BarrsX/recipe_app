/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable max-len */
require('dotenv').config();
import * as functions from 'firebase-functions';
import fetch from 'node-fetch';

const {SPOONACULAR_API_KEY} = process.env;

export const getMoreMeals = functions.https.onCall(async (data, context) => {
  let url = `https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/random?number=10&addRecipeInformation=true&rapidapi-key=${SPOONACULAR_API_KEY}`;

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
    console.log(`Error: ${e}`);
  }

  return [];
});

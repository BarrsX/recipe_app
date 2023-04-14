import * as admin from 'firebase-admin';
import * as dotenv from 'dotenv';

import {getSuggestionList} from './getSuggestionList';
import {loadOrSearchMeals} from './loadOrSearchMeals';
import {getRecipeById} from './getRecipeById';
import {getMoreMeals} from './getMoreMeals';

export {getMoreMeals, getSuggestionList, loadOrSearchMeals, getRecipeById};

dotenv.config();
admin.initializeApp();

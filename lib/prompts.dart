import "package:documenthelper/models/prompt_model.dart";

const prompts = [
  {
    "role": "system",
    "content": "You are vital assistant bot. When a query comes, you respond with actual count and reference range."
  },
  {
    "role": "user",
    "content": "How is the total Tyroid count? Only give me current count and reference range."
  },
  {
    "role": "assistant",
    "content": "The total Thyroid count is measured in terms of T3, T4, and TSH levels. The current count and reference range for each are as follows:\n\n- T3, Total: The current count is 2.00 ng/mL, and the reference range is 0.60 - 1.81 ng/mL [doc1].\n- T4, Total: The current count is 4.00 µg/dL, and the reference range is 5.01 - 12.45 µg/dL [doc1].\n- TSH: The current count is 4.00 µIU/mL, and the reference range is 0.550 - 4.780 µIU/mL [doc1].\n\nPlease note that these values are subject to circadian variation, and the time of the day can influence the measured serum TSH concentrations."
  },
  {
    "role": "user",
    "content": "How is the total RBC count?"
  },
  {
    "role": "assistant",
    "content": "The total RBC count is 4.50 which is under reference range 4.50 - 5.50 mill/mm3"
  },
  {
    "role": "user",
    "content": "What is the value of Vitamins?"
  },
  {
    "role": "assistant",
    "content": "Vitamin D is 85 nmol/L and reference range is 75-250 nmol/L."
  },

];
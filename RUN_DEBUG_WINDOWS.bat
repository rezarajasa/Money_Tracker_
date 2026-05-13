// Supabase Edge Function: update-currency-rates
// Mengambil kurs terbaru lalu menyimpan ke tabel public.currency_rates.
// Default provider: Frankfurter public API. Untuk provider lain, ubah CURRENCY_API_URL.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const popularCodes = [
  'USD', 'EUR', 'GBP', 'JPY', 'SAR', 'AED', 'SGD', 'MYR', 'AUD', 'CAD',
  'CHF', 'CNY', 'HKD', 'KRW', 'THB', 'INR', 'PHP', 'VND', 'TRY',
];

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !serviceRoleKey) {
      return json({ error: 'Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY' }, 500);
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });

    const providerUrl = Deno.env.get('CURRENCY_API_URL') ?? 'https://api.frankfurter.dev/v1/latest?base=IDR';
    const response = await fetch(providerUrl);

    if (!response.ok) {
      return json({ error: 'Currency provider request failed', status: response.status }, 502);
    }

    const payload = await response.json();
    const rates = payload.rates ?? {};
    const today = new Date().toISOString().slice(0, 10);

    const rows = popularCodes
      .filter((code) => typeof rates[code] === 'number' && rates[code] > 0)
      .map((code) => {
        // Provider base IDR berarti: 1 IDR = rates[CODE] CODE.
        // Database menyimpan: 1 CODE = X IDR, jadi perlu dibalik.
        const idrPerUnit = 1 / rates[code];
        const spread = idrPerUnit * 0.0025;
        return {
          base_code: 'IDR',
          currency_code: code,
          buy_rate: Number((idrPerUnit - spread).toFixed(8)),
          sell_rate: Number((idrPerUnit + spread).toFixed(8)),
          rate_date: today,
          provider: 'frankfurter',
          is_manual: false,
          raw_payload: payload,
        };
      });

    rows.push({
      base_code: 'IDR',
      currency_code: 'IDR',
      buy_rate: 1,
      sell_rate: 1,
      rate_date: today,
      provider: 'base',
      is_manual: false,
      raw_payload: { base: 'IDR' },
    });

    if (rows.length === 1) {
      return json({ error: 'Provider did not return supported rates for selected currencies', sample_keys: Object.keys(rates).slice(0, 10) }, 422);
    }

    const { error } = await supabase
      .from('currency_rates')
      .upsert(rows, { onConflict: 'base_code,currency_code,rate_date,provider' });

    if (error) {
      return json({ error: error.message }, 500);
    }

    return json({ success: true, inserted_or_updated: rows.length, provider: 'frankfurter', rate_date: today });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

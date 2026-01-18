/**
 * Supabase Edge Function: Auto-Expire Events
 *
 * This function runs daily to mark past events as expired.
 * Deploy to Supabase using: supabase functions deploy auto-expire-events
 *
 * Schedule using Supabase Cron Jobs (in SQL):
 *
 * SELECT cron.schedule(
 *   'auto-expire-events-daily',
 *   '0 0 * * *',  -- Runs at midnight every day
 *   $$
 *   SELECT
 *     net.http_post(
 *       url:='<YOUR_SUPABASE_URL>/functions/v1/auto-expire-events',
 *       headers:='{"Authorization": "Bearer <YOUR_SERVICE_ROLE_KEY>", "Content-Type": "application/json"}'::jsonb,
 *       body:='{}'::jsonb
 *     ) AS request_id;
 *   $$
 * );
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create Supabase client with service role key
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    const now = new Date().toISOString();

    // Find all events that have ended but not marked as expired
    const { data: expiredEvents, error: fetchError } = await supabaseClient
      .from("events")
      .select("id, title, end_datetime")
      .eq("is_expired", false)
      .lt("end_datetime", now);

    if (fetchError) {
      throw new Error(`Error fetching events: ${fetchError.message}`);
    }

    if (!expiredEvents || expiredEvents.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No events to expire",
          expiredCount: 0,
          timestamp: now,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Extract IDs of events to expire
    const expiredIds = expiredEvents.map((event) => event.id);

    // Mark all expired events
    const { error: updateError } = await supabaseClient
      .from("events")
      .update({ is_expired: true })
      .in("id", expiredIds);

    if (updateError) {
      throw new Error(`Error updating events: ${updateError.message}`);
    }

    // Log expired events
    console.log(`Auto-expired ${expiredIds.length} events:`);
    expiredEvents.forEach((event) => {
      console.log(
        `  - ${event.title} (ID: ${event.id}, ended: ${event.end_datetime})`
      );
    });

    return new Response(
      JSON.stringify({
        success: true,
        message: `Successfully expired ${expiredIds.length} events`,
        expiredCount: expiredIds.length,
        expiredEvents: expiredEvents.map((e) => ({ id: e.id, title: e.title })),
        timestamp: now,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    console.error("Auto-expire function error:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});

-- ============================================================
-- ESQUEMA SUPABASE — Automatización n8n: Empleo + Clientes
-- Isaac Urdaneta (IDUCDEV)
-- ============================================================

-- Extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLA: jobs (ofertas de empleo)
-- ============================================================
CREATE TABLE jobs (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title           TEXT NOT NULL,
  company         TEXT NOT NULL,
  location        TEXT,
  description     TEXT,
  url             TEXT UNIQUE NOT NULL,
  source          TEXT NOT NULL,                    -- linkedin, indeed, upwork, weworkremotely, etc.
  salary          TEXT,
  job_type        TEXT,                              -- full-time, part-time, contract, freelance
  remote          BOOLEAN DEFAULT true,
  skills_detected TEXT[],                            -- ['Flutter', 'Dart', 'n8n', ...]
  relevance_score INTEGER DEFAULT 0,                 -- 0-100 (calculado por IA)
  relevance_label TEXT DEFAULT 'pending',            -- pending, high, medium, low
  status          TEXT DEFAULT 'active',             -- active, expired, applied
  raw_data        JSONB,                             -- datos crudos del scraping
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_jobs_relevance ON jobs(relevance_score DESC);
CREATE INDEX idx_jobs_created ON jobs(created_at DESC);
CREATE INDEX idx_jobs_source ON jobs(source);
CREATE INDEX idx_jobs_status ON jobs(status);

-- ============================================================
-- TABLA: applications (postulaciones enviadas)
-- ============================================================
CREATE TABLE applications (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id          UUID REFERENCES jobs(id) ON DELETE CASCADE,
  company         TEXT NOT NULL,
  position        TEXT NOT NULL,
  cover_letter_id UUID,                              -- FK a cover_letters
  status          TEXT DEFAULT 'pending',            -- pending, applied, interview, offer, rejected, ghosted
  applied_at      TIMESTAMPTZ,
  interview_date  TIMESTAMPTZ,
  notes           TEXT,
  follow_up_date  TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_created ON applications(created_at DESC);

-- ============================================================
-- TABLA: cover_letters (cartas de presentación generadas por IA)
-- ============================================================
CREATE TABLE cover_letters (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id          UUID REFERENCES jobs(id) ON DELETE CASCADE,
  content         TEXT NOT NULL,
  subject         TEXT,
  tone            TEXT DEFAULT 'professional',       -- professional, casual, passionate
  model_used      TEXT DEFAULT 'gpt-4',
  tokens_used     INTEGER DEFAULT 0,
  generated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TABLA: leads (prospectos de clientes)
-- ============================================================
CREATE TABLE leads (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name    TEXT NOT NULL,
  website         TEXT,
  contact_name    TEXT,
  contact_email   TEXT,
  contact_phone   TEXT,
  linkedin_url    TEXT,
  industry        TEXT,
  size            TEXT,                               -- startup, smb, enterprise
  tech_stack      TEXT[],                             -- tecnologías detectadas
  pain_points     TEXT[],                             -- detectados por IA
  service_match   TEXT[],                             -- ['flutter_app', 'n8n_automation', 'both']
  score           INTEGER DEFAULT 0,                  -- 0-100
  score_label     TEXT DEFAULT 'cold',                -- hot, warm, cold
  status          TEXT DEFAULT 'new',                 -- new, contacted, proposal_sent, negotiation, won, lost
  source          TEXT,                               -- upwork, linkedin, producthunt, referral, etc.
  notes           TEXT,
  raw_data        JSONB,
  assigned_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_leads_score ON leads(score DESC);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_created ON leads(created_at DESC);

-- ============================================================
-- TABLA: outreach_log (historial de comunicación con leads)
-- ============================================================
CREATE TABLE outreach_log (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lead_id         UUID REFERENCES leads(id) ON DELETE CASCADE,
  channel         TEXT NOT NULL,                      -- email, linkedin_dm, whatsapp, telegram, phone
  direction       TEXT DEFAULT 'outbound',            -- outbound, inbound
  subject         TEXT,
  content         TEXT NOT NULL,
  status          TEXT DEFAULT 'sent',                -- sent, delivered, read, replied, bounced, failed
  sequence_step   INTEGER DEFAULT 1,                  -- 1: first, 2: follow-up, 3: final
  sent_at         TIMESTAMPTZ DEFAULT NOW(),
  replied_at      TIMESTAMPTZ,
  metadata        JSONB
);

CREATE INDEX idx_outreach_lead ON outreach_log(lead_id);
CREATE INDEX idx_outreach_status ON outreach_log(status);
CREATE INDEX idx_outreach_sent ON outreach_log(sent_at DESC);

-- ============================================================
-- TABLA: crm_pipeline (pipeline visual de ventas)
-- ============================================================
CREATE TABLE crm_pipeline (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  lead_id         UUID REFERENCES leads(id) ON DELETE CASCADE,
  stage           TEXT NOT NULL DEFAULT 'lead',       -- lead, contacted, meeting_done, proposal, negotiation, closed_won, closed_lost
  probability     INTEGER DEFAULT 10,                 -- 0-100
  estimated_value INTEGER,                            -- en USD
  proposal_url    TEXT,
  closed_at       TIMESTAMPTZ,
  lost_reason     TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pipeline_stage ON crm_pipeline(stage);
CREATE UNIQUE INDEX idx_pipeline_lead ON crm_pipeline(lead_id);  -- un lead por pipeline

-- ============================================================
-- FUNCIÓN: actualizar updated_at automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas
CREATE TRIGGER trg_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_applications_updated_at BEFORE UPDATE ON applications FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_crm_pipeline_updated_at BEFORE UPDATE ON crm_pipeline FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- RLS (Row Level Security) — recomendado para Supabase en producción
-- ============================================================
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE cover_letters ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE outreach_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_pipeline ENABLE ROW LEVEL SECURITY;

-- Política: solo el owner (tu usuario) puede ver todo
-- Ajusta según tu configuración de Supabase Auth
CREATE POLICY "Owner full access on jobs" ON jobs FOR ALL USING (true);
CREATE POLICY "Owner full access on applications" ON applications FOR ALL USING (true);
CREATE POLICY "Owner full access on cover_letters" ON cover_letters FOR ALL USING (true);
CREATE POLICY "Owner full access on leads" ON leads FOR ALL USING (true);
CREATE POLICY "Owner full access on outreach_log" ON outreach_log FOR ALL USING (true);
CREATE POLICY "Owner full access on crm_pipeline" ON crm_pipeline FOR ALL USING (true);

-- Nota: En producción, cambia `USING (true)` por `USING (auth.uid() = 'tu-user-id')`

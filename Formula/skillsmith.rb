class BuildAnAgent < Formula
  desc "Claude Code skills pipeline for building and auditing AI agents"
  homepage "https://github.com/andychanfp/skillsmith"
  url "https://github.com/andychanfp/skillsmith/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "8a9e96085167a7db1396f496750a924cac622eefefc87ee9ea1eb791f4759015"
  license "MIT"

  SKILLS = %w[
    agent-audit
    agent-audit-benchmark
    agent-audit-grade
    agent-audit-lint
    agent-audit-optimise
    agent-audit-test
    agent-build
    agent-evaluate
    agent-fix
    agent-plan
    agent-quality
    agent-ship
  ].freeze

  def install
    SKILLS.each do |skill|
      src = buildpath/".claude/skills/#{skill}"
      next unless src.directory?
      skill_dst = share/"skillsmith/skills/#{skill}"
      skill_dst.mkpath
      src.children.each { |f| FileUtils.cp_r(f, skill_dst) }
      FileUtils.rm_rf(skill_dst/"run")
    end
  end

  def post_install
    claude_dir = Pathname.new("#{Dir.home}/.claude")
    unless claude_dir.directory?
      opoo "~/.claude not found — is Claude Code installed? " \
           "After installing Claude Code, run: brew reinstall skillsmith"
      return
    end

    claude_skills = claude_dir/"skills"
    claude_skills.mkpath

    SKILLS.each do |skill|
      src = share/"skillsmith/skills/#{skill}"
      dst = claude_skills/skill
      dst.rmtree if dst.exist?
      FileUtils.cp_r(src, dst)
    end

    ohai "#{SKILLS.size} skills installed to ~/.claude/skills/"
  end

  def caveats
    <<~EOS
      Open any Claude Code session and type /agent-plan to start planning, or /agent-ship to plan and build in one go.

      To update skills to the latest version:
        brew upgrade build-an-agent

      If ~/.claude was not found at install time, install Claude Code first:
        https://claude.ai/download
      Then run: brew reinstall skillsmith
    EOS
  end
end

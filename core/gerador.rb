require 'yaml'

def gera_individuo(turma)
  individuo = []
  5.times do |dia|
    individuo[dia] = []
    4.times do |periodo|
      individuo[dia][periodo] = @disciplinas.sample
    end
  end
  {individuo: individuo, acertos: calcula_acertos(individuo, turma), turma: turma}
end

def calcula_acertos(individuo, turma)
  acerto = 0
  disciplinas_quantidade = {}
  5.times do |dia|
    4.times do |periodo|
      disciplinas_quantidade[individuo[dia][periodo]] = (disciplinas_quantidade[individuo[dia][periodo]] || 0) + 1
    end
  end
  disciplinas_quantidade.each do |disciplina, quantidade|
    acerto += 1 if quantidade == @turmas[turma][disciplina]
  end
  acerto
end

def cruzamento(x, y)
  individuo = []
  5.times do |dia|
    individuo[dia] = []
    4.times do |periodo|
      individuo[dia][periodo] = if rand(1) == 1 then x[:individuo][dia][periodo] else y[:individuo][dia][periodo] end
    end
  end
  {individuo: individuo, acertos: calcula_acertos(individuo, x[:turma]), turma: x[:turma]}
end

def nova_geracao(geracao)
  nova_geracao = []

  if geracao.empty?
    # Primeira geracao
    @turmas.each do |turma, disciplinas|
      2.times do
        nova_geracao << gera_individuo(turma)
      end
    end
  else
    quantidade = geracao.size + rand(50)
    quantidade.times do
      nova_geracao << cruzamento(geracao.sample, geracao.sample)
    end
  end
 nova_geracao
end

@turmas = YAML.load_file('modelos/turmas.yml')
@disciplinas = YAML.load_file('modelos/disciplinas.yml')
@individuos = []
@metas = {}
geracao = []

# Calcula o valor maximo de acertos
@turmas.each do |turma, disciplinas|
  disciplinas.each do |disciplina, quantidade|
    @metas[turma] = (@metas[turma] || 0) + quantidade
  end
end

@individuos << geracao

melhor_individuo = nil
1000.times do
  geracao = nova_geracao(geracao)
  geracao.each do |individuo|
    melhor_individuo = individuo if melhor_individuo.nil? || individuo[:acertos] > melhor_individuo[:acertos]
  end

  @individuos << geracao

  break if melhor_individuo[:acertos] == @metas[melhor_individuo[:turma]]
end


puts melhor_individuo[:acertos]
puts melhor_individuo



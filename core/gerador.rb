require 'yaml'

def gera_individuo(turma)
  individuo = []
  5.times do |dia|
    individuo[dia] = []
    4.times do |periodo|
      individuo[dia][periodo] = @disciplinas.sample
    end
  end
  acertos = calcula_acertos(individuo, turma)
  individuo = {individuo: individuo, acertos: acertos, turma: turma}
  @melhor_individuo = individuo if @melhor_individuo.nil? || acertos > @melhor_individuo[:acertos]
  individuo
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
  acertos = calcula_acertos(individuo, x[:turma])
  individuo = {individuo: individuo, acertos: acertos, turma: x[:turma]}
  @melhor_individuo = individuo if @melhor_individuo.nil? || (acertos > @melhor_individuo[:acertos])
  individuo
end

def nova_geracao(geracao)
  nova_geracao = []

  if geracao.empty?
    # Primeira geracao
    @turmas.each do |turma, disciplinas|
      5000.times do
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
@melhor_individuo

geracao = []

# Calcula o valor maximo de acertos
@turmas.each do |turma, disciplinas|
  disciplinas.each do |disciplina, quantidade|
    @metas[turma] = (@metas[turma] || 0) + quantidade
  end
end

@individuos << geracao

melhor_individuo = nil
10.times do |i|
  geracao = nova_geracao(geracao)

  puts "Geracao #{i} - tamanho #{geracao.size} - melhor #{@melhor_individuo[:acertos]}"

  @individuos << geracao

  break if @melhor_individuo && (@melhor_individuo[:acertos] == @metas[@melhor_individuo[:turma]])
end


puts @melhor_individuo[:acertos]
puts @melhor_individuo



// This is a generated file. Not intended for manual editing.
package org.elixir_lang.psi.impl;

import java.util.List;
import org.jetbrains.annotations.*;
import com.intellij.lang.ASTNode;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementVisitor;
import com.intellij.psi.util.PsiTreeUtil;
import static org.elixir_lang.psi.ElixirTypes.*;
import com.intellij.extapi.psi.ASTWrapperPsiElement;
import org.elixir_lang.psi.*;
import com.ericsson.otp.erlang.OtpErlangObject;

public class ElixirUnknownBaseWholeNumberImpl extends ASTWrapperPsiElement implements ElixirUnknownBaseWholeNumber {

  public ElixirUnknownBaseWholeNumberImpl(ASTNode node) {
    super(node);
  }

  public void accept(@NotNull PsiElementVisitor visitor) {
    if (visitor instanceof ElixirVisitor) ((ElixirVisitor)visitor).visitUnknownBaseWholeNumber(this);
    else super.accept(visitor);
  }

  @Override
  @NotNull
  public List<ElixirUnknownBaseDigits> getUnknownBaseDigitsList() {
    return PsiTreeUtil.getChildrenOfTypeAsList(this, ElixirUnknownBaseDigits.class);
  }

  @Override
  @NotNull
  public PsiElement getUnknownWholeNumberBase() {
    return findNotNullChildByType(UNKNOWN_WHOLE_NUMBER_BASE);
  }

  @NotNull
  public int base() {
    return ElixirPsiImplUtil.base(this);
  }

  @NotNull
  public List<Digits> digitsList() {
    return ElixirPsiImplUtil.digitsList(this);
  }

  @NotNull
  public OtpErlangObject quote() {
    return ElixirPsiImplUtil.quote(this);
  }

}

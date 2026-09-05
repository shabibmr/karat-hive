import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { DocumentType, VendorDocument, VendorProfile } from '@prisma/client';
import { PrismaService } from '../../../platform/db/prisma.service';
import type { DbTx } from '../../../platform/db/tx';

export type CreateVendorProfileInput = {
  userId: string;
  legalBusinessName: string;
  tradingName: string;
  tradeLicenceNumber: string;
  licenceExpiryDate: Date;
  businessAddress: string;
  contactPersonName: string;
  businessEmail: string;
};

@Injectable()
export class VendorOnboardingRepository {
  constructor(private readonly prisma: PrismaService) {}

  createProfile(tx: DbTx, input: CreateVendorProfileInput): Promise<VendorProfile> {
    return tx.vendorProfile.create({
      data: {
        userId: input.userId,
        legalBusinessName: input.legalBusinessName,
        tradingName: input.tradingName,
        tradeLicenceNumber: input.tradeLicenceNumber,
        licenceExpiryDate: input.licenceExpiryDate,
        businessAddress: input.businessAddress,
        contactPersonName: input.contactPersonName,
        businessEmail: input.businessEmail,
        verificationState: 'PENDING_VERIFICATION',
      },
    });
  }

  findById(id: string): Promise<VendorProfile | null> {
    return this.prisma.vendorProfile.findUnique({ where: { id } });
  }

  findByUserId(userId: string): Promise<VendorProfile | null> {
    return this.prisma.vendorProfile.findUnique({ where: { userId } });
  }

  licenceExists(tradeLicenceNumber: string): Promise<VendorProfile | null> {
    return this.prisma.vendorProfile.findUnique({ where: { tradeLicenceNumber } });
  }

  async distinctDocumentTypes(vendorProfileId: string): Promise<DocumentType[]> {
    const rows = await this.prisma.vendorDocument.findMany({
      where: { vendorProfileId },
      distinct: ['documentType'],
      select: { documentType: true },
    });
    return rows.map((r) => r.documentType);
  }

  listDocuments(vendorProfileId: string): Promise<VendorDocument[]> {
    return this.prisma.vendorDocument.findMany({
      where: { vendorProfileId },
      orderBy: { uploadedAt: 'desc' },
    });
  }

  countCategories(vendorProfileId: string): Promise<number> {
    return this.prisma.vendorCategory.count({ where: { vendorProfileId } });
  }

  countRegions(vendorProfileId: string): Promise<number> {
    return this.prisma.vendorRegion.count({ where: { vendorProfileId } });
  }

  async replaceCategories(tx: DbTx, vendorProfileId: string, categoryIds: string[]): Promise<void> {
    await tx.vendorCategory.deleteMany({ where: { vendorProfileId } });
    await tx.vendorCategory.createMany({
      data: categoryIds.map((categoryId) => ({ vendorProfileId, categoryId })),
      skipDuplicates: true,
    });
  }

  async replaceRegions(tx: DbTx, vendorProfileId: string, regionIds: string[]): Promise<void> {
    await tx.vendorRegion.deleteMany({ where: { vendorProfileId } });
    await tx.vendorRegion.createMany({
      data: regionIds.map((regionId) => ({ vendorProfileId, regionId })),
      skipDuplicates: true,
    });
  }

  addDocument(
    tx: DbTx,
    input: {
      vendorProfileId: string;
      documentType: DocumentType;
      mediaId: string;
      expiryDate: Date | null;
      uploadedAt: Date;
    },
  ): Promise<VendorDocument> {
    return tx.vendorDocument.create({
      data: {
        vendorProfileId: input.vendorProfileId,
        documentType: input.documentType,
        mediaId: input.mediaId,
        expiryDate: input.expiryDate,
        uploadedAt: input.uploadedAt,
      },
    });
  }

  update(
    tx: DbTx,
    id: string,
    data: Prisma.VendorProfileUncheckedUpdateInput,
  ): Promise<VendorProfile> {
    return tx.vendorProfile.update({ where: { id }, data });
  }
}
